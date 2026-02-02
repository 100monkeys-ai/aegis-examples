"""
Code Reviewer Agent

This agent reviews code changes (pull requests) and provides:
- Security vulnerability analysis
- Code quality suggestions
- Best practice recommendations
"""

import os
from openai import OpenAI

client = OpenAI(api_key=os.environ["OPENAI_API_KEY"])


def fetch_pr_diff(pr_number):
    """Fetch PR diff from GitHub via MCP."""
    # Mock implementation
    return """
    diff --git a/src/auth.py b/src/auth.py
    +def authenticate(password):
    +    if password == "admin123":  # SECURITY: Hardcoded password!
    +        return True
    """


def review_code(diff):
    """Review code using GPT-4."""
    prompt = f"""You are a senior code reviewer. Analyze this diff and provide:
1. Security vulnerabilities
2. Code quality issues
3. Best practice suggestions

Diff:
{diff}
"""
    
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "system", "content": "You are an expert code reviewer."},
                  {"role": "user", "content": prompt}],
    )
    
    return response.choices[0].message.content


def main():
    pr_number = os.environ.get("PR_NUMBER", "123")
    
    print(f"Reviewing PR #{pr_number}")
    diff = fetch_pr_diff(pr_number)
    
    print("Analyzing code...")
    review = review_code(diff)
    
    print("\n=== Code Review ===")
    print(review)
    
    # Save review
    with open(f"/data/outputs/review_pr{pr_number}.md", "w") as f:
        f.write(f"# Code Review for PR #{pr_number}\n\n")
        f.write(review)
    
    print(f"\nReview saved to /data/outputs/review_pr{pr_number}.md")


if __name__ == "__main__":
    main()
