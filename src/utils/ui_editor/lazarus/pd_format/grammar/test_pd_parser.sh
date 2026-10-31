#!/bin/bash
# test_pd_parser.sh

PASS=0
FAIL=0

check() {
  local name="$1" input="$2" expected="$3"
  local out
  out=$(printf '%b' "$input" | ./pd_parser 2>&1)
  if echo "$out" | grep -q "$expected"; then
    echo "PASS: $name"
    ((PASS++))
  else
    echo "FAIL: $name"
    echo "  Input:    $input"
    echo "  Expected: $expected"
    echo "  Got:      $out"
    ((FAIL++))
  fi
}

# Базовые
check "L1" "L1" "1 => 1"
check "L1|L2" "L1|L2" "1 => 3"
check "L1,L2" "L1, L2" "1 => 1"
check "L1|L2,EMPTY,L3" "L1|L2, EMPTY_PAGE, L3" "1 => 3"
check "EMPTY_PAGE" "EMPTY_PAGE" "1 => 0"

# Граничные
check "L33" "L33" "1 => 4294967296"
check "L56" "L56" "1 => 36028797018963968"
check "L57" "L57" "1 => 72057594037927936"

# Ошибки LED
check "L0" "L0" "LED index out of bounds 1..57: L0"
check "L58" "L58" "LED index out of bounds 1..57: L58"
check "L99999999999" "L99999999999" "Error: Line 1: LED index out of bounds 1..57: L99999999999"
check "L1,L58" "L1, L58" "LED index out of bounds 1..57: L58"
check "L1,L99,L2" "L1, L99, L2" "LED index out of bounds 1..57: L99"

# Синтаксические ошибки
check "L1 L2" "L1 L2" "syntax error"
check "L1," "L1," "syntax error"
check ",L1" ",L1" "syntax error"

# Комментарии
check "// comment" "L1 // c" "1 => 1"
check "/* */" "L1 /* c */" "1 => 1"
check "unterminated /*" "L1\n/* unfinished" "Unterminated block comment"

echo ""
echo "PASS: $PASS, FAIL: $FAIL"
