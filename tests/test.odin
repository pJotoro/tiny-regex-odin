/*
 * Testing various regex-patterns
 */

 package test

import "core:fmt"
import "core:strings"
import regex "regex"

import "core:log"

Test_Vector :: struct {
	expected: bool,
	pattern:  cstring,
	haystack: cstring,
	length:   i32,
}

test_vectors := []Test_Vector{
	{ true,  "\\d",                       "5",                      1},
	{ true,  "\\w+",                      "hej",                    3},
	{ true,  "\\s",                       "\t \n",                  1},
	{ false, "\\S",                       "\t \n",                  0},
	{ true,  "[\\s]",                     "\t \n",                  1},
	{ false, "[\\S]",                     "\t \n",                  0},
	{ false, "\\D",                       "5",                      0},
	{ false, "\\W+",                      "hej",                    0},
	{ true,  "[0-9]+",                    "12345",                  5},
	{ true,  "\\D",                       "hej",                    1},
	{ false, "\\d",                       "hej",                    0},
	{ true,  "[^\\w]",                    "\\",                     1},
	{ true,  "[\\W]",                     "\\",                     1},
	{ false, "[\\w]",                     "\\",                     0},
	{ true,  "[^\\d]",                    "d",                      1},
	{ false, "[\\d]",                     "d",                      0},
	{ false, "[^\\D]",                    "d",                      0},
	{ true,  "[\\D]",                     "d",                      1},
	{ true,  "^.*\\\\.*$",                "c:\\Tools",              8},
	{ true,  "^[\\+-]*[\\d]+$",           "+27",                    3},
	{ true,  "[abc]",                     "1c2",                    1},
	{ false, "[abc]",                     "1C2",                    0},
	{ true,  "[1-5]+",                    "0123456789",             5},
	{ true,  "[.2]",                      "1C2",                    1},
	{ true,  "a*$",                       "Xaa",                    2},
	{ true,  "a*$",                       "Xaa",                    2},
	{ true,  "[a-h]+",                    "abcdefghxxx",            8},
	{ false, "[a-h]+",                    "ABCDEFGH",               0},
	{ true,  "[A-H]+",                    "ABCDEFGH",               8},
	{ false, "[A-H]+",                    "abcdefgh",               0},
	{ true,  "[^\\s]+",                   "abc def",                3},
	{ true,  "[^fc]+",                    "abc def",                2},
	{ true,  "[^d\\sf]+",                 "abc def",                3},
	{ true,  "\n",                        "abc\ndef",               1},
	{ true,  "b.\\s*\n",                  "aa\r\nbb\r\ncc\r\n\r\n", 4},
	{ true,  ".*c",                       "abcabc",                 6},
	{ true,  ".+c",                       "abcabc",                 6},
	{ true,  "[b-z].*",                   "ab",                     1},
	{ true,  "b[k-z]*",                   "ab",                     1},
	{ false, "[0-9]",                     "  - ",                   0},
	{ true,  "[^0-9]",                    "  - ",                   1},
	{ true,  "0|",                        "0|",                     2},
	{ false, "\\d\\d:\\d\\d:\\d\\d",      "0s:00:00",               0},
	{ false, "\\d\\d:\\d\\d:\\d\\d",      "000:00",                 0},
	{ false, "\\d\\d:\\d\\d:\\d\\d",      "00:0000",                0},
	{ false, "\\d\\d:\\d\\d:\\d\\d",      "100:0:00",               0},
	{ false, "\\d\\d:\\d\\d:\\d\\d",      "00:100:00",              0},
	{ false, "\\d\\d:\\d\\d:\\d\\d",      "0:00:100",               0},
	{ true,  "\\d\\d?:\\d\\d?:\\d\\d?",   "0:0:0",                  5},
	{ true,  "\\d\\d?:\\d\\d?:\\d\\d?",   "0:00:0",                 6},
	{ true,  "\\d\\d?:\\d\\d?:\\d\\d?",   "0:0:00",                 5},
	{ true,  "\\d\\d?:\\d\\d?:\\d\\d?",   "00:0:0",                 6},
	{ true,  "\\d\\d?:\\d\\d?:\\d\\d?",   "00:00:0",                7},
	{ true,  "\\d\\d?:\\d\\d?:\\d\\d?",   "00:0:00",                6},
	{ true,  "\\d\\d?:\\d\\d?:\\d\\d?",   "0:00:00",                6},
	{ true,  "\\d\\d?:\\d\\d?:\\d\\d?",   "00:00:00",               7},
	{ true,  "[Hh]ello [Ww]orld\\s*[!]?", "Hello world !",          12},
	{ true,  "[Hh]ello [Ww]orld\\s*[!]?", "hello world !",          12},
	{ true,  "[Hh]ello [Ww]orld\\s*[!]?", "Hello World !",          12},
	{ true,  "[Hh]ello [Ww]orld\\s*[!]?", "Hello world!   ",        11},
	{ true,  "[Hh]ello [Ww]orld\\s*[!]?", "Hello world  !",         13},
	{ true,  "[Hh]ello [Ww]orld\\s*[!]?", "hello World    !",       15},
	{ false, "\\d\\d?:\\d\\d?:\\d\\d?",   "a:0",                    0}, /* Failing test case reported in https://github.com/kokke/tiny-regex-c/issues/12 */
/*
	{ true,  "[^\\w][^-1-4]",     ")T",          2      },
	{ true,  "[^\\w][^-1-4]",     ")^",          2      },
	{ true,  "[^\\w][^-1-4]",     "*)",          2      },
	{ true,  "[^\\w][^-1-4]",     "!.",          2      },
	{ true,  "[^\\w][^-1-4]",     " x",          2      },
	{ true,  "[^\\w][^-1-4]",     "$b",          2      },
*/
	{ true,  ".?bar",                     "real_bar",               4            },
	{ false, ".?bar",                     "real_foo",               0            },
	{ false, "X?Y",                       "Z",                      0            },
	{ true, "[a-z]+\nbreak",              "blahblah\nbreak",        14           },
	{ true, "[a-z\\s]+\nbreak",           "bla bla \nbreak",        14           },
};

//void re_print(re_t);

main :: proc()
{
		using regex

		nfailed: uint = 0
		i:       int  = 0
		ntests:  int  = len(test_vectors)

		for test in test_vectors
		{
			i += 1

			length: i32
			m := re_match(test.pattern, test.haystack, &length)

			if !test.expected {
				if m != -1 {
					fmt.printf("\n");
					re_print(re_compile(test.pattern));
					fmt.printf("[%v/%v]: pattern '%v' matched '%v' unexpectedly, matched %v chars. \n", i, ntests, test.pattern, test.haystack, length)
					nfailed += 1
				}
			} else {
				if m == -1 {
					fmt.printf("\n")
					re_print(re_compile(test.pattern));
					fmt.printf("[%v/%v]: pattern '%v' didn't match '%v' as expected. \n", i, ntests, test.pattern, test.haystack)
					nfailed += 1
				} else if length != test.length {
					fmt.printf("[%v/%v]: pattern '%v' matched '%v' chars of '%v'; expected '%v'. \n", i, ntests, test.pattern, length, test.haystack, test.length)
					nfailed += 1
				}
			}
		}

		// printf("\n");
		fmt.printf("%v/%v tests succeeded.\n", ntests - int(nfailed), ntests);
		fmt.printf("\n");
		fmt.printf("\n");
		fmt.printf("\n");
}
