/*
 *
 * Mini regex-module inspired by Rob Pike's regex code described in:
 *
 * http://www.cs.princeton.edu/courses/archive/spr09/cos333/beautiful.html
 *
 *
 *
 * Supports:
 * ---------
 *   '.'        Dot, matches any character
 *   '^'        Start anchor, matches beginning of string
 *   '$'        End anchor, matches end of string
 *   '*'        Asterisk, match zero or more (greedy)
 *   '+'        Plus, match one or more (greedy)
 *   '?'        Question, match zero or one (non-greedy)
 *   '[abc]'    Character class, match if one of {'a', 'b', 'c'}
 *   '[^abc]'   Inverted class, match if NOT one of {'a', 'b', 'c'} -- NOTE: feature is currently broken!
 *   '[a-zA-Z]' Character ranges, the character set of the ranges { a-z | A-Z }
 *   '\s'       Whitespace, \t \f \r \n \v and spaces
 *   '\S'       Non-whitespace
 *   '\w'       Alphanumeric, [a-zA-Z0-9_]
 *   '\W'       Non-alphanumeric
 *   '\d'       Digits, [0-9]
 *   '\D'       Non-digits
 *
 *
 */

package odin_tiny_regex

foreign import lib "re.lib"
import "core:c"

/* Define to 0 if you DON'T want '.' to match '\r' + '\n' */
RE_DOT_MATCHED_NEWLINE :: 1

re_t :: ^regex_t

foreign lib {
	/* Compile regex string pattern to a regex_t-array. */
	re_compile :: proc(pattern: cstring) -> re_t ---

	/* Find matches of the compiled pattern inside text. */
	re_matchp :: proc(pattern: re_t, text: cstring, matchLength: ^c.int) -> c.int ---

	/* Find matches of the txt pattern inside text (will compile automatically first). */
	re_match :: proc(pattern: cstring, text: cstring, matchLength: ^c.int) -> c.int ---
}

/* Definitions: */

MAX_REGEXP_OBJECTS :: 30 /* Max number of regex symbols in expression. */
MAX_CHAR_CLASS_LEN :: 40 /* Max length of character-class buffer in.   */

UNUSED :: 0
DOT :: 1
BEGIN :: 2
END :: 3
QUESTIONMARK :: 4
STAR :: 5
PLUS :: 6
CHAR :: 7
CHAR_CLASS :: 8
INV_CHAR_CLASS :: 9
DIGIT :: 10
NON_DIGIT :: 11
ALPHA :: 12
NON_ALPHA :: 13
WHITESPACE :: 14
NOT_WHITESPACE :: 15

regex_t :: struct {
	type: u8, 		   /* CHAR, STAR, etc.                      */
	u: struct #raw_union {
		ch: u8, 	   /*      the character itself             */
		ccl: [^]u8,  /*  OR  a pointer to characters in class */
	},
}

foreign lib {
	re_print :: proc(pattern: ^regex_t) ---
}