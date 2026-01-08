# CrewAI A2A Server

A production-ready A2A (Agent-to-Agent) protocol server with CrewAI agent integration.

## 🧱 Architecture

```
A2A Client
        ↓
A2A Server (A2A Protocol)
        ↓
CrewAI Agent Executor
        ↓
CrewAI Agent
        ↓
LLM (OpenAI / Ollama / etc.)
```

## 📁 Project Structure

```
DAMAC/
├── app/
│   ├── __init__.py
│   ├── agent.py          # CrewAI agent definition
│   ├── crew.py           # Task and crew logic
│   ├── schemas.py        # Pydantic models (legacy)
│   ├── agent_executor.py # A2A agent executor
│   └── main.py           # A2A server entry point
├── requirements.txt
├── .env.example
└── README.md
```

## 🚀 Setup & Installation

### 1. Create a virtual environment (recommended)

```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure environment variables

Copy `.env.example` to `.env` and add your OpenAI API key:

```bash
cp .env.example .env
```

Then edit `.env`:

```env
OPENAI_API_KEY=sk-your-actual-openai-key-here
```

### 4. Run the A2A server

```bash
python -m app.main
```

Or with custom host/port:

```bash
python -m app.main --host 0.0.0.0 --port 10001
```

The server will be available at:
- **A2A Server**: http://localhost:10001
- **Agent Card**: http://localhost:10001/.well-known/agent-card.json

## 📡 A2A Protocol Usage

This server implements the [A2A (Agent-to-Agent) Protocol](https://a2a-protocol.org), which provides a standardized way for agents to communicate.

### Agent Card Discovery

The agent card describes the agent's capabilities and is available at:

```bash
curl http://localhost:10001/.well-known/agent-card.json
```

### Using an A2A Client

You can use any A2A-compatible client to interact with the agent. For example, using the A2A CLI client from the samples:

```bash
# Navigate to the A2A samples CLI client
cd a2a-samples/samples/python/hosts/cli

# Connect to your agent
uvicorn app.main:app --agent http://localhost:10001
```

### Direct A2A Protocol Requests

The server accepts A2A protocol-compliant requests. Refer to the [A2A Protocol Documentation](https://a2a-protocol.org) for the complete API specification.

## 🧠 How It Works

1. **A2A Server** receives the request via A2A protocol
2. **Agent Executor** extracts the user input from the request context
3. **CrewAI Agent** processes the query with defined role and goal
4. **LLM** (OpenAI) generates the response
5. **Result** is returned as an A2A artifact with text content

## 🔧 Configuration

### Agent Configuration

Edit `app/agent.py` to customize the agent's role, goal, and backstory:

```python
def get_agent():
    return Agent(
        role="Your Custom Role",
        goal="Your custom goal",
        backstory="Your custom backstory",
        verbose=True
    )
```

### Adding More Agents

You can extend the crew with multiple agents in `app/crew.py`:

```python
agent1 = get_agent()
agent2 = Agent(role="Researcher", goal="Research topics", ...)

crew = Crew(
    agents=[agent1, agent2],
    tasks=[task1, task2],
    process="sequential"
)
```

## 🔥 Production Notes

### Current Implementation
- ✅ A2A protocol compliance
- ✅ Clean separation of concerns
- ✅ Stateless API design
- ✅ Agent card discovery
- ✅ Standardized agent communication

### Recommended Upgrades
- [ ] Background job processing (Celery/RQ)
- [ ] Rate limiting
- [ ] Request logging and monitoring
- [ ] Agent memory (vector DB integration)
- [ ] Streaming responses (SSE support)
- [ ] Docker containerization
- [ ] Unit and integration tests
- [ ] Authentication support

## 🐛 Troubleshooting

### Import Errors
If you get import errors, make sure you're running from the project root:

```bash
cd /Users/ayushkumar/Documents/Lyzr2/DAMAC
uvicorn app.main:app --reload
```

### OpenAI API Errors
Make sure your `.env` file has a valid OpenAI API key and the file is in the project root.

### A2A Protocol Errors
Ensure you have installed all dependencies including `a2a-sdk`:
```bash
pip install -r requirements.txt
```

### Port Already in Use
If port 10001 is already in use, specify a different port:
```bash
python -m app.main --port 8080
```

## 📚 Next Steps

1. **Multiple Agents**: Add specialist agents (Researcher, Writer, Analyst)
2. **RAG Integration**: Add FAISS or pgvector for knowledge retrieval
3. **Streaming Support**: Enable SSE streaming for real-time responses
4. **Deployment**: Dockerize and deploy to AWS/GCP/Azure
5. **Advanced Routing**: LangGraph-style agent orchestration
6. **A2A Multi-Agent**: Connect multiple A2A agents together

## 🔗 Learn More

- [A2A Protocol Documentation](https://a2a-protocol.org)
- [CrewAI Documentation](https://docs.crewai.com/introduction)
- [A2A Samples Repository](https://github.com/a2aproject/a2a-samples)

## 📄 License

MIT

