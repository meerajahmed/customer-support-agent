#!/usr/bin/env bash
set -u
OUT="evidence"
mkdir -p "$OUT"
ALL="$OUT/ALL_TESTS_combined.txt"
: > "$ALL"

run_test () {   # $1=file-label  $2=title  $3=json payload
  local file="$OUT/$1.txt"
  {
    echo "=============================================================="
    echo "$2"
    echo "Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    echo "\$ agentcore invoke '$3'"
    echo "--------------------------------------------------------------"
    uv run agentcore invoke "$3" 2>&1
    echo
  } | tee "$file" >> "$ALL"
  cat "$file"
}

run_test test1_order_tracking  "TEST 1 - Order Tracking" \
 '{"prompt": "Can you track order ORD-001?", "customer_id": "CUST-123", "session_id": "t1"}'

run_test test2_refund          "TEST 2 - Refund Processing" \
 '{"prompt": "I want to return my Kindle Paperwhite (ORD-002). Please initiate a refund.", "customer_id": "CUST-123", "session_id": "t2"}'

run_test test3_rag             "TEST 3 - Knowledge Base (RAG)" \
 '{"prompt": "What are the benefits of the Platinum loyalty tier?", "customer_id": "CUST-123", "session_id": "t3"}'

run_test test4a_memory_sessionA "TEST 4 - Long-Term Memory - Session A (introduce yourself)" \
 '{"prompt": "Hi, I am Jane. I prefer concise responses.", "customer_id": "CUST-123", "session_id": "s-A"}'

echo ">>> Waiting 60s for AgentCore Memory extraction (minimum is 30s)..."
sleep 60

run_test test4b_memory_sessionB "TEST 4 - Long-Term Memory - Session B (NEW session, same customer)" \
 '{"prompt": "Do you remember my name and communication preference?", "customer_id": "CUST-123", "session_id": "s-B"}'

run_test test5_loyalty         "TEST 5 - Loyalty Discount (Code Interpreter)" \
 '{"prompt": "I am a Gold member with 4250 points. Calculate my discount on a $150 standard order.", "customer_id": "CUST-123", "session_id": "t5"}'

run_test test6_browser         "TEST 6 - Browser Tool" \
 '{"prompt": "Go to https://www.udacity.com and tell me the page title.", "customer_id": "CUST-123", "session_id": "t6"}'

echo
echo "Done. Evidence saved in ./$OUT/ (combined file: $ALL)"
