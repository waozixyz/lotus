# Nasu Integration Plan - Flattening the Hierarchy

## Executive Summary

This plan details how to integrate the Nasu sprite editor from its current nested subdirectory structure into the main Lotus project build system, following the established pattern of `appl/*.tal` → `bin/*.rom`.

## Current State Analysis

### Current Structure
```
lotus/
├── nasu/                    # ❌ Separate subdirectory with its own build system
│   ├── src/
│   │   ├── nasu.tal        # Main application (34KB)
│   │   ├── manifest.tal    # UI system (8KB)
│   │   └── assets.tal      # Assets (3.3KB)
│   ├── etc/                # ❌ Duplicate etc/ directory
│   │   ├── *.chr           # Asset files
│   │   ├── *.icn           # Icon files
│   │   ├── *.tal           # Asset definitions
│   │   └── nasu.c
│   ├── makefile            # ❌ Separate build system
│   └── README.md
├── appl/                    # ✅ Application sources
│   ├── evoti.tal
│   └── inbe.tal
├── src/                     # ✅ Main system sources
│   └── potato.tal
├── etc/                     # ✅ System assets
└── bin/                     # ✅ Built ROMs
```

### Problems with Current Structure
1. **Nested build system** - Nasu has its own makefile and doesn't integrate with main build
2. **Duplicate directories** - Both `nasu/etc/` and `etc/` exist
3. **Multi-file complexity** - Nasu requires 3 source files (nasu.tal + manifest.tal + assets.tal)
4. **Stale references** - `etc/loader.tal` references deleted `etc/nasu.rom`
5. **No integration** - Main build doesn't know about Nasu source

## Integration Strategy

### Phase 1: Prepare the Build System

#### 1.1 Update Main Makefile

Add special handling for Nasu's multi-file architecture:

```makefile
# Existing variables
ID=potato
DIR=~/roms
ASM=uxncli ${DIR}/drifblim.rom
LIN=uxncli ${DIR}/uxnlin.rom
EMU=uxn11
ROM=bin/${ID}.rom

# Application patterns
APPL_TAL=$(wildcard appl/*.tal)
APPL_ROM=$(patsubst appl/%.tal,bin/%.rom,$(APPL_TAL))

all: ${ROM} appl bin/nasu.rom

# Nasu-specific build (multi-file assembly)
bin/nasu.rom: appl/nasu.tal appl/nasu-manifest.tal appl/nasu-assets.tal
	@ mkdir -p bin
	@ cat appl/nasu.tal appl/nasu-manifest.tal appl/nasu-assets.tal | ${ASM} - bin/nasu.rom

# Existing patterns
bin/%.rom: appl/%.tal
	@ mkdir -p bin
	@ ${ASM} $< $@
```

#### 1.2 Add Nasu-Specific Targets

```makefile
# Nasu testing
nasu-test: bin/nasu.rom
	@ ${EMU} bin/nasu.rom assets/ako10x10.chr

# Nasu archive (standalone version)
nasu-archive: bin/nasu.rom
	@ cat appl/nasu.tal appl/nasu-manifest.tal appl/nasu-assets.tal | \
	  sed 's/~[^[:space:]]\+//' > bin/nasu-standalone.tal
	@ ${ASM} bin/nasu-standalone.tal bin/nasu-standalone.rom
```

### Phase 2: Flatten Directory Structure

#### 2.1 Create Organized assets/ Subdirectories

```bash
# Create organized directory structure
mkdir -p assets/{fonts,icons,menu,graphics,audio,definitions,nasu,nametables}
```

#### 2.2 Move Source Files to appl/

```bash
# Move and rename Nasu source files
mv nasu/src/nasu.tal appl/nasu.tal
mv nasu/src/manifest.tal appl/nasu-manifest.tal
mv nasu/src/assets.tal appl/nasu-assets.tal
```

**Rationale:**
- Keeps all application sources in `appl/`
- Adds `nasu-` prefix to prevent filename conflicts
- Maintains separation of concerns (main, manifest, assets)

#### 2.3 Consolidate ALL Assets to assets/ (FLAT)

```bash
# === Move Nasu assets (flat) ===
mv nasu/etc/*.chr assets/
mv nasu/etc/*.icn assets/
mv nasu/etc/*.tal assets/
mv nasu/etc/nasu.c etc/

# === Consolidate etc/ assets (flat) ===
mv etc/*.chr assets/
mv etc/*.icn assets/
mv etc/*.uf2 assets/
mv etc/*.pcm assets/
mv etc/*.nmt assets/
```

**Rationale:**
- **Single flat assets/ directory** - All assets in one place
- **No subdirectories** (except assets/menu/ which already exists)
- **etc/ only for utilities** - System .tal tools remain
- **Minimal path updates** - Most paths stay the same

#### 2.3 Move Documentation

```bash
# Move Nasu README to main docs
cat nasu/README.md >> docs/NASU.md
rm nasu/README.md

# Nasu LICENSE is same as lotus (MIT), can be removed
rm nasu/LICENSE

# Move build config if needed
mv nasu/.build.yml .github/workflows/nasu.yml 2>/dev/null || rm nasu/.build.yml
```

### Phase 2.4: Rename ONLY Ambiguous Assets

**Problem:** Generic names like `logo.chr`, `back.chr`, `next.chr` are confusing.

**Analysis:** Most assets already have clear names (`ako10x10.chr`, `cibo10x10.icn`, etc.). Only 3 files are ambiguous:
- `logo.chr` - Whose logo?
- `back.chr` - Back button for which app?
- `next.chr` - Next button for which app?

**Solution:** Rename only the confusing ones:

```bash
# Rename ONLY ambiguous evoti assets
mv assets/logo.chr assets/evoti-logo.chr
mv assets/back.chr assets/evoti-back.chr
mv assets/next.chr assets/evoti-next.chr

# All other assets keep their existing names (they're already clear)
# nasu/etc/ assets: ako10x10.chr, cibo10x10.icn, etc. - already descriptive
# System assets: font.chr, lotus.chr, icons10x10.chr - already clear
```

#### Update Source References:

**In `appl/evoti.tal` (3 changes):**
```tal
@logo "assets/evoti-logo.chr $1
&back "assets/evoti-back.chr $1
&next "assets/evoti-next.chr $1
```

**In `appl/nasu-assets.tal` and `appl/nasu-manifest.tal`:**
```tal
"etc/ako10x10.chr" → "assets/ako10x10.chr"
"etc/cibo10x10.icn" → "assets/cibo10x10.icn"
"etc/dir10x10.chr" → "assets/dir10x10.chr"
"etc/kata.icn" → "assets/kata.icn"
"etc/block8.icn" → "assets/block8.icn"
```

#### Naming Convention Summary:
- **Ambiguous names** → Add app prefix: `evoti-logo.chr`
- **Already descriptive names** → Keep as-is: `ako10x10.chr`, `cibo10x10.icn`
- **System assets** → Keep as-is: `font.chr`, `lotus.chr`, `icons10x10.chr`
- **Menu icons** → Keep in `assets/menu/` (shared)

### Phase 3: Update Source References

#### 3.1 Update Asset Paths in Nasu Source

**In `appl/nasu-assets.tal` and `appl/nasu-manifest.tal`:**
```tal
( Old paths → New paths )
"etc/ako10x10.chr" → "assets/ako10x10.chr"
"etc/cibo10x10.icn" → "assets/cibo10x10.icn"
"etc/dir10x10.chr" → "assets/dir10x10.chr"
"etc/kata.icn" → "assets/kata.icn"
"etc/block8.icn" → "assets/block8.icn"
```

**Note:** Since we're keeping assets/ flat, most existing paths like `"assets/logo.chr"` don't need to change!

#### 3.2 Fix Stale Reference in loader.tal

#### 3.1 Fix Stale Reference

Update `etc/loader.tal` line 25:
```tal
( OLD: "etc/nasu.rom" )
( NEW: "bin/nasu.rom" )
```

#### 3.2 Update Asset Paths

In `appl/nasu-assets.tal` and `appl/nasu-manifest.tal`, update asset paths:
- `etc/ako10x10.chr` → `assets/ako10x10.chr`
- `etc/cibo10x10.icn` → `assets/cibo10x10.icn`
- etc.

### Phase 4: Clean Up

#### 4.1 Remove Nasu Subdirectory

```bash
# After verifying all files are moved
rm -rf nasu/
```

#### 4.2 Update .gitignore

Ensure `.gitignore` covers Nasu build outputs:
```
bin/nasu.rom
bin/nasu.rom.sym
bin/nasu-standalone.*
```

## Final Structure

```
lotus/
├── appl/                    # ✅ All application sources
│   ├── evoti.tal
│   ├── inbe.tal
│   ├── nasu.tal            # ✅ Main Nasu application
│   ├── nasu-manifest.tal   # ✅ Nasu UI system
│   └── nasu-assets.tal     # ✅ Nasu assets
├── src/
│   └── potato.tal
├── etc/                     # ✅ System utilities and asset definitions
│   ├── block8.tal          # ✅ Moved from nasu/etc/
│   ├── nametable.tal       # ✅ Moved from nasu/etc/
│   ├── appicon3x3.tal      # ✅ Moved from nasu/etc/
│   ├── specter8.tal        # ✅ Moved from nasu/etc/
│   ├── nasu.c              # ✅ C reference implementation
│   └── loader.tal          # ✅ Updated to reference bin/nasu.rom
├── assets/                  # ✅ All binary assets
│   ├── ako10x10.chr        # ✅ Moved from nasu/etc/
│   ├── cibo10x10.icn       # ✅ Moved from nasu/etc/
│   ├── kata.icn            # ✅ Moved from nasu/etc/
│   ├── block8.icn          # ✅ Moved from nasu/etc/
│   ├── dir10x10.chr        # ✅ Moved from nasu/etc/
│   └── spritesheet10x10.chr # ✅ Moved from nasu/etc/
├── bin/                     # ✅ All built ROMs
│   ├── potato.rom
│   ├── evoti.rom
│   ├── inbe.rom
│   └── nasu.rom            # ✅ Built from appl/nasu*.tal
├── makefile                 # ✅ Updated with Nasu targets
└── NASU_INTEGRATION_PLAN.md # This document
```

## Build Commands

After integration:

```bash
# Build everything (including Nasu)
make all

# Build only Nasu
make bin/nasu.rom

# Test Nasu with sample assets
make nasu-test

# Run Nasu
make run APP=nasu

# Create standalone archive
make nasu-archive
```

## Directory Structure Decision: Keep etc/ vs assets/

### Analysis of Current Usage

**etc/ contains:**
- **System utilities** (meta.tal, error.tal, clock.tal, bomb.tal, loader.tal)
- **System fonts** (font.chr, font.icn, akane20x10.icn)
- **Firmware** (chicago12.uf2, sapphire14.uf2)
- **System icons** (icons10x10.chr, ss10x10.chr, uxn3x3.chr)
- **Audio samples** (cym1.pcm, sin.pcm)
- **Nametables** (.nmt files for sprite memory mapping)

**assets/ contains:**
- **Application-specific graphics** (logo.chr, back.chr, next.chr, lotus.chr)
- **Menu icons** (menu/book.chr, menu/clock.chr, menu/gear.chr, menu/group.chr)
- **Asset definitions** (font.tal, emoji.tal)

### Code Usage Patterns

Applications in `appl/` reference files like:
```tal
@logo "assets/logo.chr $1
@back "assets/back.chr $1
```

System utilities in `etc/` are standalone tools, not referenced by applications.

### Recommendation: **CONSOLIDATE TO assets/ ONLY (FLAT STRUCTURE)**

**Rationale:**
1. **etc/ is a Unix convention** for system configuration, but this is a Uxn project
2. **Current distinction is inconsistent** - fonts in both, arbitrary separation
3. **Simpler is better** - single flat directory for all assets
4. **Applications already use "assets/"** prefix in paths
5. **Flat structure** - No subdirectories, easier to navigate and reference
6. **System utilities can remain in etc/** - Only .tal utility files stay

### Revised Structure

```
lotus/
├── appl/                    # All applications
│   ├── evoti.tal
│   ├── inbe.tal
│   ├── nasu.tal
│   ├── nasu-manifest.tal
│   └── nasu-assets.tal
├── src/                     # Main system
│   └── potato.tal
├── assets/                  # ✅ ALL assets (flat, consolidated)
│   ├── logo.chr
│   ├── back.chr
│   ├── next.chr
│   ├── lotus.chr
│   ├── font.chr            # from etc/
│   ├── font.icn            # from etc/
│   ├── akane20x10.icn      # from etc/
│   ├── chicago12.uf2       # from etc/
│   ├── sapphire14.uf2      # from etc/
│   ├── icons10x10.chr      # from etc/
│   ├── ss10x10.chr         # from etc/
│   ├── uxn3x3.chr          # from etc/
│   ├── saver.chr           # from etc/
│   ├── cym1.pcm            # from etc/
│   ├── sin.pcm             # from etc/
│   ├── font.tal
│   ├── emoji.tal
│   ├── block8.tal          # from nasu/etc/
│   ├── nametable.tal       # from nasu/etc/
│   ├── appicon3x3.tal      # from nasu/etc/
│   ├── specter8.tal        # from nasu/etc/
│   ├── ako10x10.chr        # from nasu/etc/
│   ├── cibo10x10.icn       # from nasu/etc/
│   ├── kata.icn            # from nasu/etc/
│   ├── block8.icn          # from nasu/etc/
│   ├── dir10x10.chr        # from nasu/etc/
│   ├── spritesheet10x10.chr # from nasu/etc/
│   ├── icons10x10.chr.nmt  # from etc/
│   ├── ss10x10.chr.nmt     # from etc/
│   └── uxn3x3.chr.nmt      # from etc/
│   └── menu/               # Only subdirectory: menu icons
│       ├── book.chr
│       ├── clock.chr
│       ├── gear.chr
│       └── group.chr
├── etc/                    # ✅ System utilities ONLY (.tal files)
│   ├── meta.tal           # Metadata reader
│   ├── error.tal          # Error handler
│   ├── clock.tal          # Clock utility
│   ├── bomb.tal           # Bomb utility
│   ├── loader.tal         # Loader (updated to bin/nasu.rom)
│   └── nasu.c             # C reference (documentation)
└── bin/                    # Built ROMs
    ├── potato.rom
    ├── evoti.rom
    ├── inbe.rom
    └── nasu.rom
```

### Migration Steps for Consolidation

1. **Move all assets from etc/ to assets/ (flat):**
   ```bash
   # All binary assets
   mv etc/*.chr assets/
   mv etc/*.icn assets/
   mv etc/*.uf2 assets/
   mv etc/*.pcm assets/
   mv etc/*.nmt assets/

   # Asset definition files
   mv etc/*.tal assets/ 2>/dev/null || true

   # Keep only utilities in etc/
   # (meta.tal, error.tal, clock.tal, bomb.tal, loader.tal stay)
   ```

2. **Move all Nasu assets to assets/ (flat):**
   ```bash
   # All Nasu assets
   mv nasu/etc/*.chr assets/
   mv nasu/etc/*.icn assets/
   mv nasu/etc/*.tal assets/

   # C reference stays in etc/
   mv nasu/etc/nasu.c etc/
   ```

3. **Result:**
   - `assets/` contains all asset files (flat structure)
   - `etc/` contains only utility .tal files
   - No path updates needed in source code!

### Benefits of Consolidation

1. **Single source of truth** - All assets in one place
2. **Logical organization** - Subdirectories by type
3. **Easier to find** - No guessing which directory
4. **Simpler paths** - Consistent `assets/` prefix
5. **Scalable** - Easy to add new asset types
6. **etc/ becomes meaningful** - Only system utilities

## Benefits of This Approach

1. **Unified Build System** - Single makefile builds everything
2. **Consistent Structure** - Follows established `appl/` → `bin/` pattern
3. **No Duplication** - Single `assets/` and `etc/` directory
4. **Clear Separation** - Main, manifest, and assets clearly named
5. **Maintainable** - Easy to understand and modify
6. **Scalable** - Pattern can be used for other complex applications

## Migration Steps

1. ✅ Analysis complete (4 parallel agents)
2. ⏳ Update makefile with Nasu targets
3. ⏳ Move source files to `appl/`
4. ⏳ Move assets to `assets/` and `etc/`
5. ⏳ Update file references in source
6. ⏳ Fix stale reference in `etc/loader.tal`
7. ⏳ Test build: `make bin/nasu.rom`
8. ⏳ Test run: `make run APP=nasu`
9. ⏳ Remove `nasu/` directory
10. ⏳ Update documentation

## Special Considerations

### Multi-File Assembly
Nasu requires concatenating three files. The makefile handles this with:
```makefile
bin/nasu.rom: appl/nasu.tal appl/nasu-manifest.tal appl/nasu-assets.tal
	@ cat $^ | ${ASM} - $@
```

### Asset Path Updates
All asset paths in Nasu source files need to be updated:
- Old: `etc/filename.chr`
- New: `assets/filename.chr`

### Backward Compatibility
The `etc/loader.tal` reference should be updated to point to `bin/nasu.rom`

## Testing Checklist

- [ ] Build succeeds: `make bin/nasu.rom`
- [ ] ROM file generated in `bin/`
- [ ] Can run Nasu: `make run APP=nasu`
- [ ] Assets load correctly
- [ ] No stale references remain
- [ ] All tests pass: `make nasu-test`
- [ ] Documentation updated

## Rollback Plan

If issues arise:
1. Restore from git: `git checkout .`
2. Keep `nasu/` directory as backup
3. Document issues and adjust plan

## Next Steps

Await user approval to proceed with:
1. Makefile updates
2. File moves
3. Reference updates
4. Testing and cleanup
