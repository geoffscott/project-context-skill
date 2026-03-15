# Context Optimizer Feature

**Status:** Concept / Design Phase

## Problem

Chaotic information (zips, Google Drive sprawl, random uploads) can't be efficiently loaded into project contexts. Users manually organize files, losing time and semantic information. The project-context skill manages where work lives, but doesn't optimize *what information* gets loaded into which context.

## Solution

A feature that:
1. **Ingests** files (zip uploads, Google Drive scans, raw uploads)
2. **Classifies** each file using agent knowledge of user's projects and work
3. **Places** files in appropriate project contexts automatically
4. **Optionally enriches** (extract summaries, tag, create notes about origin/relevance)

Result: Clean, relevant information loaded into the right project context, ready for work.

## Key Insight

This isn't file management. This is **information optimization for context windows**. The value is in making chaotic input loadable into focused project contexts.

## Possible Implementation

### Option 1: Build from Scratch
- Bash/Python script that ingests files
- Routes each file through agent for classification
- Places in appropriate project/context folder
- Creates metadata about why it was placed there

### Option 2: Use Existing Skill
- Research if ClawHub has a document organization skill
- Wrap it with project-context awareness
- Integrate classification logic with skill's knowledge of projects

## System Dependencies

### PDF Libraries
For reading and extracting text from PDFs:
```bash
python3 -m pip install PyPDF2 pdfrw reportlab
```

Or via apt:
```bash
apt-get install python3-reportlab python3-pypdf2
```

- **PyPDF2** — Read/merge PDFs, extract form fields
- **pdfrw** — Fill PDF form fields (AcroForms)
- **reportlab** — Generate PDFs from scratch if needed

### Other Document Formats
- **Word:** `python-docx` (read .docx files)
- **Excel:** `openpyxl` or `xlrd` (read .xlsx, .xls)
- **PowerPoint:** `python-pptx` (read .pptx)

## Workflow

```
User uploads zip / connects Google Drive
  ↓
Skill extracts and enumerates files
  ↓
For each file:
  - Understand what it is (type, content summary)
  - Ask agent: "Which project does this belong to?"
  - (Optional) Extract key info, create summary
  ↓
Place in project/context/{category}/{subcategory}/
  ↓
Commit changes with explanation
  ↓
User gets clean, organized project context
```

## Integration Points

- **project-context commands:** Use to determine available projects and structures
- **Document analysis:** Extract text from PDFs, Word, Excel, PowerPoint; detect file types
- **Agent knowledge:** Understanding what each project is about, what files are relevant
- **Metadata creation:** Track origin, decision rationale, extracted summaries

## Questions to Explore

1. Which existing skills/tools exist for document organization on ClawHub?
2. How much intelligence should classification have? (Simple heuristics vs. full reasoning?)
3. Should users review/confirm placement before commit, or trust the agent?
4. How do we handle ambiguous files (belongs to multiple projects)?

## Success Criteria

- Can ingest a messy zip/Drive with mixed content
- Correctly categorizes and places 80%+ of files
- Creates useful metadata (summaries, tags, context notes)
- User ends up with clean, navigable project structure
