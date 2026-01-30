# CogniVault Memory Bridge - Technical Implementation

**Integration:** CogniVault ↔ Aluna-Memory (Mem0)  
**Version:** 1.0.0  
**Date:** 2026-01-30  
**Author:** Rob "The Sounds Guy" Barenbrug  
**Built by:** VERITAS - 150% Production Standard

---

## 🎯 Architecture Overview

```
┌──────────────────────────────────────────────────────────────┐
│                      User Interface                          │
│              (Streamlit - Port 50004)                        │
└─────────────────────┬────────────────────────────────────────┘
                      │
                      │ Document Upload
                      │ (WhatsApp, ChatGPT, Audio, PDF, etc.)
                      ▼
┌──────────────────────────────────────────────────────────────┐
│                     CogniVault Core                          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Document Processors                                  │   │
│  │  ├─ WhatsApp Export Processor                        │   │
│  │  ├─ ChatGPT Export Processor                         │   │
│  │  ├─ Audio Transcription (Whisper)                    │   │
│  │  ├─ PDF/DOCX/TXT Processor                           │   │
│  │  ├─ Image EXIF Extractor                             │   │
│  │  └─ ZIP Archive Handler                              │   │
│  └────────────────────┬─────────────────────────────────┘   │
│                       │                                       │
│  ┌────────────────────▼─────────────────────────────────┐   │
│  │  TF-IDF Vector Store (Local)                         │   │
│  │  - Fast keyword search                                │   │
│  │  - Document similarity                                │   │
│  │  - Local-first indexing                               │   │
│  └────────────────────┬─────────────────────────────────┘   │
│                       │                                       │
│  ┌────────────────────▼─────────────────────────────────┐   │
│  │  Memory Bridge API                                    │   │
│  │  - Format conversion                                  │   │
│  │  - Entity extraction                                  │   │
│  │  - Context enrichment                                 │   │
│  │  - Relationship mapping                               │   │
│  └────────────────────┬─────────────────────────────────┘   │
└───────────────────────┼───────────────────────────────────────┘
                        │
                        │ HTTP API
                        │ POST /memory/add
                        │ GET  /memory/search
                        │ GET  /memory/context
                        ▼
┌──────────────────────────────────────────────────────────────┐
│                  Aluna-Memory (Mem0)                         │
│                  (Port 50003)                                │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Mem0 Core                                            │   │
│  │  ├─ Semantic Embeddings (via LLM)                    │   │
│  │  ├─ Graph Database (relationships)                   │   │
│  │  ├─ Long-term Memory Store                           │   │
│  │  └─ Context-aware Retrieval                          │   │
│  └────────────────────┬─────────────────────────────────┘   │
│                       │                                       │
│  ┌────────────────────▼─────────────────────────────────┐   │
│  │  OpenMemory Interface                                 │   │
│  │  - Standardized memory format                         │   │
│  │  - Cross-system compatibility                         │   │
│  │  - MCP integration ready                              │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
                        │
                        │ Claude MCP
                        │ (Model Context Protocol)
                        ▼
             ┌─────────────────────┐
             │  Claude Desktop      │
             │  (Windows/Mac)       │
             └─────────────────────┘
```

---

## 🔌 Memory Bridge Implementation

### File: `memory_bridge.py`

```python
"""
CogniVault Memory Bridge
Connects local TF-IDF search with Aluna-Memory (Mem0) semantic storage
"""

import os
import requests
import json
from typing import Dict, List, Optional, Any
from datetime import datetime
import hashlib

class MemoryBridge:
    """Bridge between CogniVault and Aluna-Memory"""
    
    def __init__(self, aluna_url: Optional[str] = None):
        """
        Initialize Memory Bridge
        
        Args:
            aluna_url: URL of Aluna-Memory service
                      Default: http://aluna-memory:8000 (Docker)
                      or http://localhost:50003 (local dev)
        """
        self.aluna_url = aluna_url or os.getenv(
            'ALUNA_MEMORY_URL', 
            'http://aluna-memory:8000'
        )
        self.session = requests.Session()
        self.session.headers.update({
            'Content-Type': 'application/json',
            'User-Agent': 'CogniVault-Memory-Bridge/1.0'
        })
    
    def health_check(self) -> bool:
        """Check if Aluna-Memory is accessible"""
        try:
            response = self.session.get(
                f"{self.aluna_url}/health",
                timeout=5
            )
            return response.status_code == 200
        except Exception as e:
            print(f"Aluna-Memory health check failed: {e}")
            return False
    
    def add_document_memory(
        self,
        content: str,
        metadata: Dict[str, Any],
        doc_type: str,
        user_id: str = "default_user"
    ) -> Optional[str]:
        """
        Add document to long-term memory
        
        Args:
            content: Document text content
            metadata: Document metadata (author, date, source, etc.)
            doc_type: Type of document (whatsapp, chatgpt, audio, pdf, etc.)
            user_id: User identifier for memory isolation
            
        Returns:
            Memory ID if successful, None otherwise
        """
        try:
            # Generate unique document ID
            doc_id = hashlib.sha256(
                f"{content[:100]}{metadata.get('timestamp', '')}".encode()
            ).hexdigest()[:16]
            
            # Format for Mem0
            memory_data = {
                "messages": [
                    {
                        "role": "system",
                        "content": f"Storing {doc_type} document"
                    },
                    {
                        "role": "user",
                        "content": content
                    }
                ],
                "user_id": user_id,
                "metadata": {
                    **metadata,
                    "doc_type": doc_type,
                    "doc_id": doc_id,
                    "source": "cognivault",
                    "indexed_at": datetime.utcnow().isoformat()
                }
            }
            
            # Send to Aluna-Memory
            response = self.session.post(
                f"{self.aluna_url}/v1/memories",
                json=memory_data,
                timeout=30
            )
            
            if response.status_code == 201:
                result = response.json()
                memory_id = result.get('id') or result.get('memory_id')
                print(f"✓ Added to memory: {memory_id}")
                return memory_id
            else:
                print(f"✗ Failed to add memory: {response.status_code}")
                print(f"  Response: {response.text}")
                return None
                
        except Exception as e:
            print(f"✗ Error adding document to memory: {e}")
            return None
    
    def search_memories(
        self,
        query: str,
        user_id: str = "default_user",
        limit: int = 10,
        doc_type: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Search memories semantically
        
        Args:
            query: Search query
            user_id: User identifier
            limit: Maximum results
            doc_type: Filter by document type
            
        Returns:
            List of matching memories with metadata
        """
        try:
            # Build search request
            search_data = {
                "query": query,
                "user_id": user_id,
                "limit": limit
            }
            
            if doc_type:
                search_data["filters"] = {
                    "doc_type": doc_type
                }
            
            # Query Aluna-Memory
            response = self.session.post(
                f"{self.aluna_url}/v1/memories/search",
                json=search_data,
                timeout=30
            )
            
            if response.status_code == 200:
                results = response.json()
                memories = results.get('memories', [])
                print(f"✓ Found {len(memories)} memories")
                return memories
            else:
                print(f"✗ Search failed: {response.status_code}")
                return []
                
        except Exception as e:
            print(f"✗ Error searching memories: {e}")
            return []
    
    def get_context(
        self,
        query: str,
        user_id: str = "default_user",
        max_tokens: int = 2000
    ) -> str:
        """
        Get relevant context for a query
        
        Args:
            query: Query to get context for
            user_id: User identifier
            max_tokens: Maximum context length
            
        Returns:
            Formatted context string
        """
        try:
            memories = self.search_memories(query, user_id, limit=5)
            
            if not memories:
                return ""
            
            # Format context
            context_parts = []
            total_length = 0
            
            for memory in memories:
                content = memory.get('content', '')
                metadata = memory.get('metadata', {})
                
                # Format memory entry
                entry = f"[{metadata.get('doc_type', 'unknown')}] {content}"
                
                if total_length + len(entry) > max_tokens:
                    break
                
                context_parts.append(entry)
                total_length += len(entry)
            
            return "\n\n".join(context_parts)
            
        except Exception as e:
            print(f"✗ Error getting context: {e}")
            return ""
    
    def add_conversation_memory(
        self,
        messages: List[Dict[str, str]],
        user_id: str = "default_user",
        metadata: Optional[Dict[str, Any]] = None
    ) -> Optional[str]:
        """
        Add conversation to memory
        
        Args:
            messages: List of {role, content} messages
            user_id: User identifier
            metadata: Additional metadata
            
        Returns:
            Memory ID if successful
        """
        try:
            memory_data = {
                "messages": messages,
                "user_id": user_id,
                "metadata": {
                    **(metadata or {}),
                    "doc_type": "conversation",
                    "source": "cognivault",
                    "indexed_at": datetime.utcnow().isoformat()
                }
            }
            
            response = self.session.post(
                f"{self.aluna_url}/v1/memories",
                json=memory_data,
                timeout=30
            )
            
            if response.status_code == 201:
                result = response.json()
                memory_id = result.get('id') or result.get('memory_id')
                print(f"✓ Conversation stored: {memory_id}")
                return memory_id
            else:
                print(f"✗ Failed to store conversation: {response.status_code}")
                return None
                
        except Exception as e:
            print(f"✗ Error storing conversation: {e}")
            return None
    
    def get_all_memories(
        self,
        user_id: str = "default_user",
        limit: int = 100
    ) -> List[Dict[str, Any]]:
        """Get all memories for a user"""
        try:
            response = self.session.get(
                f"{self.aluna_url}/v1/memories",
                params={"user_id": user_id, "limit": limit},
                timeout=30
            )
            
            if response.status_code == 200:
                result = response.json()
                return result.get('memories', [])
            else:
                return []
                
        except Exception as e:
            print(f"✗ Error getting memories: {e}")
            return []
    
    def delete_memory(
        self,
        memory_id: str
    ) -> bool:
        """Delete a specific memory"""
        try:
            response = self.session.delete(
                f"{self.aluna_url}/v1/memories/{memory_id}",
                timeout=10
            )
            return response.status_code == 200
            
        except Exception as e:
            print(f"✗ Error deleting memory: {e}")
            return False
```

---

## 🔗 Integration with CogniVault Core

### Modified `app_integrated.py`

```python
# Add at the top
from memory_bridge import MemoryBridge

# Initialize in main()
memory_bridge = MemoryBridge()

# Check connection
if memory_bridge.health_check():
    st.sidebar.success("✓ Connected to Aluna-Memory")
else:
    st.sidebar.warning("⚠ Aluna-Memory offline (local mode)")

# When processing documents (in each processor)
def process_whatsapp_with_memory(file, memory_bridge):
    # Existing WhatsApp processing...
    messages = parse_whatsapp_export(file)
    
    # Add to vector store (existing)
    for msg in messages:
        vector_store.add_document(msg['content'], msg['metadata'])
    
    # Add to long-term memory (NEW)
    if memory_bridge.health_check():
        for msg in messages:
            memory_bridge.add_document_memory(
                content=msg['content'],
                metadata=msg['metadata'],
                doc_type='whatsapp',
                user_id=st.session_state.get('user_id', 'default')
            )
        st.success(f"✓ {len(messages)} messages added to long-term memory")

# Enhanced search with hybrid results
def hybrid_search(query, k=10):
    # Local TF-IDF search (fast)
    local_results = vector_store.search(query, k=k)
    
    # Semantic search via Mem0 (contextual)
    if memory_bridge.health_check():
        semantic_results = memory_bridge.search_memories(query, limit=k)
        
        # Merge and rank results
        combined_results = merge_search_results(
            local_results,
            semantic_results
        )
        return combined_results
    else:
        return local_results
```

---

## 🐳 Docker Integration

### Updated `docker-compose.yml` excerpt:

```yaml
services:
  cognivault:
    build:
      context: ./cognivault
    environment:
      - ALUNA_MEMORY_URL=http://aluna-memory:8000
      - GROQ_API_KEY=${GROQ_API_KEY}
      - GEMINI_API_KEY=${GEMINI_API_KEY}
      - NOVITA_API_KEY=${NOVITA_API_KEY}
    depends_on:
      - aluna-memory
    networks:
      - veritas-network
    
  aluna-memory:
    build:
      context: ./aluna-memory
    environment:
      - DATABASE_URL=postgresql://veritas:${POSTGRES_PASSWORD}@postgres:5432/veritas
      - REDIS_URL=redis://:${REDIS_PASSWORD}@redis:6379
      - GROQ_API_KEY=${GROQ_API_KEY}
      - GEMINI_API_KEY=${GEMINI_API_KEY}
    networks:
      - veritas-network
```

---

## 📊 Data Flow Examples

### Example 1: WhatsApp Export Processing

```python
# User uploads WhatsApp export
file = st.file_uploader("Upload WhatsApp Chat", type=['txt', 'zip'])

if file:
    # Parse WhatsApp messages
    messages = parse_whatsapp_export(file)
    # Total: 15,234 messages
    
    # Step 1: Fast local indexing (TF-IDF)
    for msg in messages:
        vector_store.add_document(
            content=msg['text'],
            metadata={
                'sender': msg['sender'],
                'timestamp': msg['timestamp'],
                'chat_name': msg['chat_name']
            }
        )
    # Result: Instant keyword search available
    
    # Step 2: Semantic memory storage (Mem0)
    for msg in messages:
        memory_bridge.add_document_memory(
            content=msg['text'],
            metadata={
                'sender': msg['sender'],
                'timestamp': msg['timestamp'],
                'chat_name': msg['chat_name']
            },
            doc_type='whatsapp',
            user_id='rob_barenbrug'
        )
    # Result: Context-aware semantic search available
    
    st.success("✓ 15,234 messages indexed and stored in long-term memory")
```

### Example 2: Hybrid Search

```python
# User searches: "discussions about AI projects"
query = "discussions about AI projects"

# Local TF-IDF search (fast, keyword-based)
local_results = vector_store.search(query, k=10)
# Returns messages containing exact keywords: "AI", "projects"

# Semantic search via Mem0 (contextual)
semantic_results = memory_bridge.search_memories(query, limit=10)
# Returns related concepts:
#  - "machine learning experiments"
#  - "LLM fine-tuning discussions"
#  - "CogniVault development notes"

# Merge and display
for result in merge_results(local_results, semantic_results):
    st.write(f"**{result['sender']}** ({result['timestamp']})")
    st.write(result['content'])
    st.write(f"Relevance: {result['score']}")
    st.divider()
```

---

## 🔐 Environment Variables

```bash
# CogniVault
GROQ_API_KEY=gsk_xxx
GEMINI_API_KEY=AIzaSyxxx
NOVITA_API_KEY=sk_xxx
ALUNA_MEMORY_URL=http://aluna-memory:8000

# Aluna-Memory
DATABASE_URL=postgresql://veritas:password@postgres:5432/veritas
REDIS_URL=redis://:password@redis:6379
GROQ_API_KEY=gsk_xxx
GEMINI_API_KEY=AIzaSyxxx
ANTHROPIC_API_KEY=sk-ant-xxx
OPENROUTER_API_KEY=sk-or-xxx
```

---

## 📈 Performance Characteristics

| Feature | TF-IDF (Local) | Mem0 (Semantic) |
|---------|----------------|-----------------|
| **Search Speed** | <50ms | 200-500ms |
| **Accuracy** | Good for keywords | Excellent for concepts |
| **Storage** | Minimal (in-memory) | PostgreSQL + Vector DB |
| **Offline** | Yes | No (requires API) |
| **Context** | No | Yes (understands relationships) |
| **Best For** | Exact keyword search | Conceptual understanding |

### Hybrid Approach Benefits:
- **Speed:** TF-IDF provides instant results
- **Accuracy:** Mem0 provides semantic understanding
- **Reliability:** Falls back to local if Mem0 unavailable
- **Scalability:** Mem0 handles large-scale memory graphs

---

## 🧪 Testing

```python
# test_memory_bridge.py
import pytest
from memory_bridge import MemoryBridge

def test_health_check():
    bridge = MemoryBridge("http://localhost:50003")
    assert bridge.health_check() == True

def test_add_document():
    bridge = MemoryBridge()
    memory_id = bridge.add_document_memory(
        content="This is a test document about AI",
        metadata={"author": "test_user"},
        doc_type="test"
    )
    assert memory_id is not None

def test_search():
    bridge = MemoryBridge()
    results = bridge.search_memories("AI projects", limit=5)
    assert len(results) <= 5

def test_context():
    bridge = MemoryBridge()
    context = bridge.get_context("AI research", max_tokens=1000)
    assert isinstance(context, str)
    assert len(context) <= 1000
```

---

## 🚀 Deployment Steps

1. **Update CogniVault** with `memory_bridge.py`
2. **Install dependencies**: `pip install requests`
3. **Update `requirements_integrated.txt`**:
   ```
   requests==2.31.0
   ```
4. **Test locally**:
   ```bash
   # Terminal 1: Start Aluna-Memory
   cd aluna-memory && docker compose up
   
   # Terminal 2: Start CogniVault
   cd cognivault && streamlit run app_integrated.py
   ```
5. **Deploy to VPS**: Run `VERITAS_VPS_COMPLETE_SETUP.sh`
6. **Verify integration**:
   ```bash
   curl http://localhost:50003/health
   curl http://localhost:50004/_stcore/health
   ```

---

## 📚 API Reference

### Memory Bridge Methods

```python
bridge = MemoryBridge(aluna_url="http://aluna-memory:8000")

# Health check
bridge.health_check() -> bool

# Add document
bridge.add_document_memory(
    content: str,
    metadata: Dict,
    doc_type: str,
    user_id: str = "default"
) -> Optional[str]

# Search
bridge.search_memories(
    query: str,
    user_id: str = "default",
    limit: int = 10,
    doc_type: Optional[str] = None
) -> List[Dict]

# Get context
bridge.get_context(
    query: str,
    user_id: str = "default",
    max_tokens: int = 2000
) -> str

# Add conversation
bridge.add_conversation_memory(
    messages: List[Dict],
    user_id: str = "default",
    metadata: Optional[Dict] = None
) -> Optional[str]

# Get all
bridge.get_all_memories(
    user_id: str = "default",
    limit: int = 100
) -> List[Dict]

# Delete
bridge.delete_memory(memory_id: str) -> bool
```

---

## 🎯 Next Steps

1. ✅ Core Memory Bridge implemented
2. ✅ Docker integration configured
3. ✅ Environment variables documented
4. ⏳ Add to CogniVault codebase
5. ⏳ Test integration locally
6. ⏳ Deploy to VPS
7. ⏳ Configure MCP for Claude Desktop
8. ⏳ Production testing and optimization

---

**Built by VERITAS - 150% Production Standard**  
**Rob "The Sounds Guy" Barenbrug**  
**2026-01-30**
