AFFiNE is a next-generation knowledge base that brings together notes, documents, and whiteboards into a single, unified workspace. It is designed with privacy and local-first principles at its core.

**Key features:**

- **Edgeless canvas**: an infinite whiteboard for free-form thinking, mind maps, and visual organization
- **Structured documents**: rich-text editor with support for headings, tables, code blocks, and embeds
- **Real-time collaboration**: multiple users can edit the same workspace simultaneously
- **Offline-first**: your data is always available, even without internet access; sync happens when reconnected
- **Self-hostable**: full control over your data with the official self-hosted server
- **Open source**: MIT-licensed, community-driven development

AFFiNE replaces a combination of tools like Notion (documents), Miro (whiteboards), and Obsidian (local notes) with a single integrated experience. It stores data in a structured binary format (CRDT-based), enabling efficient merging of concurrent edits.

The self-hosted version requires PostgreSQL (with the pgvector extension for AI features) and Redis for caching and job queues.
