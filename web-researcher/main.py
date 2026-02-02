"""
Web Researcher Agent

This agent performs deep research on a given topic by:
1. Searching the web
2. Reading articles
3. Synthesizing findings
4. Generating a comprehensive report
"""

import os
from openai import OpenAI

client = OpenAI(api_key=os.environ["OPENAI_API_KEY"])


def search_web(query):
    """Search the web using MCP search connector."""
    # Mock implementation
    return [
        {"title": "Article 1", "url": "https://example.com/1", "snippet": "..."},
        {"title": "Article 2", "url": "https://example.com/2", "snippet": "..."},
    ]


def read_article(url):
    """Read an article using MCP browser."""
    # Mock implementation
    return "Article content..."


def synthesize_research(sources):
    """Synthesize research findings with GPT-4."""
    prompt = f"Based on these sources, write a comprehensive research report:\n\n{sources}"
    
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.7,
    )
    
    return response.choices[0].message.content


def main():
    topic = "Agentic AI security challenges"
    
    print(f"Researching: {topic}")
    search_results = search_web(topic)
    
    sources = []
    for result in search_results:
        print(f"Reading: {result['title']}")
        content = read_article(result['url'])
        sources.append(f"Source: {result['title']}\n{content}")
    
    print("Synthesizing findings...")
    report = synthesize_research("\n\n".join(sources))
    
    # Save report
    with open("/data/outputs/research_report.md", "w") as f:
        f.write(f"# Research Report: {topic}\n\n")
        f.write(report)
    
    print("\nReport saved to /data/outputs/research_report.md")


if __name__ == "__main__":
    main()
