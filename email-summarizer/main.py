"""
Email Summarizer Agent

This agent connects to Gmail, fetches recent emails, and generates concise summaries.
It demonstrates:
- MCP integration (Gmail)
- Persistent memory (Cortex)
- Secure API key injection
"""

import os
from openai import OpenAI

# Initialize OpenAI client with injected API key
client = OpenAI(api_key=os.environ["OPENAI_API_KEY"])


def fetch_emails():
    """Fetch recent emails via MCP Gmail connector."""
    # This would use the MCP protocol to connect to Gmail
    # For now, returning mock data
    return [
        {"from": "boss@company.com", "subject": "Q1 Planning", "snippet": "Let's schedule a meeting..."},
        {"from": "newsletter@tech.com", "subject": "Weekly Digest", "snippet": "Top 10 tech news..."},
    ]


def summarize_with_llm(emails):
    """Generate a summary using GPT-4."""
    prompt = "Summarize these emails concisely:\n\n"
    for email in emails:
        prompt += f"From: {email['from']}\nSubject: {email['subject']}\n{email['snippet']}\n\n"
    
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}],
    )
    
    return response.choices[0].message.content


def main():
    """Main execution flow."""
    print("Fetching emails...")
    emails = fetch_emails()
    
    print(f"Found {len(emails)} emails. Generating summary...")
    summary = summarize_with_llm(emails)
    
    print("\n=== Email Summary ===")
    print(summary)
    
    # Save output
    with open("/data/outputs/summary.txt", "w") as f:
        f.write(summary)
    
    print("\nSummary saved to /data/outputs/summary.txt")


if __name__ == "__main__":
    main()
