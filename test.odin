/*
 * Testing various regex-patterns
 */

 package test

import "core:fmt"
import "core:strings"
import regex "odin_tiny_regex"

import "core:log"

OK : cstring : "1"
NOK : cstring : "0"


test_vector := [][4]cstring{
  { OK,  "\\d",                       "5",                "1"},
  { OK,  "\\w+",                      "hej",              "3"},
  { OK,  "\\s",                       "\t \n",            "1"},
  { NOK, "\\S",                       "\t \n",            "0"},
  { OK,  "[\\s]",                     "\t \n",            "1"},
  { NOK, "[\\S]",                     "\t \n",            "0"},
  { NOK, "\\D",                       "5",                "0"},
  { NOK, "\\W+",                      "hej",              "0"},
  { OK,  "[0-9]+",                    "12345",            "5"},
  { OK,  "\\D",                       "hej",              "1"},
  { NOK, "\\d",                       "hej",              "0"},
  { OK,  "[^\\w]",                    "\\",               "1"},
  { OK,  "[\\W]",                     "\\",               "1"},
  { NOK, "[\\w]",                     "\\",               "0"},
  { OK,  "[^\\d]",                    "d",                "1"},
  { NOK, "[\\d]",                     "d",                "0"},
  { NOK, "[^\\D]",                    "d",                "0"},
  { OK,  "[\\D]",                     "d",                "1"},
  { OK,  "^.*\\\\.*$",                "c:\\Tools",        "8"},
  { OK,  "^[\\+-]*[\\d]+$",           "+27",              "3"},
  { OK,  "[abc]",                     "1c2",              "1"},
  { NOK, "[abc]",                     "1C2",              "0"},
  { OK,  "[1-5]+",                    "0123456789",       "5"},
  { OK,  "[.2]",                      "1C2",              "1"},
  { OK,  "a*$",                       "Xaa",              "2"},
  { OK,  "a*$",                       "Xaa",              "2"},
  { OK,  "[a-h]+",                    "abcdefghxxx",      "8"},
  { NOK, "[a-h]+",                    "ABCDEFGH",         "0"},
  { OK,  "[A-H]+",                    "ABCDEFGH",         "8"},
  { NOK, "[A-H]+",                    "abcdefgh",         "0"},
  { OK,  "[^\\s]+",                   "abc def",          "3"},
  { OK,  "[^fc]+",                    "abc def",          "2"},
  { OK,  "[^d\\sf]+",                 "abc def",          "3"},
  { OK,  "\n",                        "abc\ndef",         "1"},
  { OK,  "b.\\s*\n",                  "aa\r\nbb\r\ncc\r\n\r\n","4"},
  { OK,  ".*c",                       "abcabc",           "6"},
  { OK,  ".+c",                       "abcabc",           "6"},
  { OK,  "[b-z].*",                   "ab",               "1"},
  { OK,  "b[k-z]*",                   "ab",               "1"},
  { NOK, "[0-9]",                     "  - ",             "0"},
  { OK,  "[^0-9]",                    "  - ",             "1"},
  { OK,  "0|",                        "0|",               "2"},
  { NOK, "\\d\\d:\\d\\d:\\d\\d",      "0s:00:00",         "0"},
  { NOK, "\\d\\d:\\d\\d:\\d\\d",      "000:00",           "0"},
  { NOK, "\\d\\d:\\d\\d:\\d\\d",      "00:0000",          "0"},
  { NOK, "\\d\\d:\\d\\d:\\d\\d",      "100:0:00",         "0"},
  { NOK, "\\d\\d:\\d\\d:\\d\\d",      "00:100:00",        "0"},
  { NOK, "\\d\\d:\\d\\d:\\d\\d",      "0:00:100",         "0"},
  { OK,  "\\d\\d?:\\d\\d?:\\d\\d?",   "0:0:0",            "5"},
  { OK,  "\\d\\d?:\\d\\d?:\\d\\d?",   "0:00:0",           "6"},
  { OK,  "\\d\\d?:\\d\\d?:\\d\\d?",   "0:0:00",           "5"},
  { OK,  "\\d\\d?:\\d\\d?:\\d\\d?",   "00:0:0",           "6"},
  { OK,  "\\d\\d?:\\d\\d?:\\d\\d?",   "00:00:0",          "7"},
  { OK,  "\\d\\d?:\\d\\d?:\\d\\d?",   "00:0:00",          "6"},
  { OK,  "\\d\\d?:\\d\\d?:\\d\\d?",   "0:00:00",          "6"},
  { OK,  "\\d\\d?:\\d\\d?:\\d\\d?",   "00:00:00",         "7"},
  { OK,  "[Hh]ello [Ww]orld\\s*[!]?", "Hello world !",    "12"},
  { OK,  "[Hh]ello [Ww]orld\\s*[!]?", "hello world !",    "12"},
  { OK,  "[Hh]ello [Ww]orld\\s*[!]?", "Hello World !",    "12"},
  { OK,  "[Hh]ello [Ww]orld\\s*[!]?", "Hello world!   ",  "11"},
  { OK,  "[Hh]ello [Ww]orld\\s*[!]?", "Hello world  !",   "13"},
  { OK,  "[Hh]ello [Ww]orld\\s*[!]?", "hello World    !", "15"},
  { NOK, "\\d\\d?:\\d\\d?:\\d\\d?",   "a:0",              "0"}, /* Failing test case reported in https://github.com/kokke/tiny-regex-c/issues/12 */
/*
  { OK,  "[^\\w][^-1-4]",     ")T",          (char*) 2      },
  { OK,  "[^\\w][^-1-4]",     ")^",          (char*) 2      },
  { OK,  "[^\\w][^-1-4]",     "*)",          (char*) 2      },
  { OK,  "[^\\w][^-1-4]",     "!.",          (char*) 2      },
  { OK,  "[^\\w][^-1-4]",     " x",          (char*) 2      },
  { OK,  "[^\\w][^-1-4]",     "$b",          (char*) 2      },
*/
  { OK,  ".?bar",                      "real_bar",        "4"		     },
  { NOK, ".?bar",                      "real_foo",        "0"		     },
  { NOK, "X?Y",                        "Z",               "0"      		 },
  { OK, "[a-z]+\nbreak",              "blahblah\nbreak",  "14"		     },
  { OK, "[a-z\\s]+\nbreak",           "bla bla \nbreak",  "14" 		  	 },
};

//void re_print(re_t);

main :: proc()
{
	using regex
    text: cstring
    pattern: cstring
    should_fail: b32
    length: int
    correctlen: int
   	ntests := size_of(test_vector) / size_of(&test_vector);
    nfailed: uint = 0
    i: uint

    for i = 0; int(i) < ntests; i += 1
    {
        pattern = test_vector[i][1]
        text = test_vector[i][2]
        should_fail = (test_vector[i][0] == NOK)
        correctlen = transmute(int)(test_vector[i][3])

        m := re_match(pattern, text, cast(^i32)(&length))

        if should_fail
        {
            if m != (-1)
            {
                fmt.printf("\n");
                re_print(re_compile(pattern));
                fmt.printf("[%v/%v]: pattern '%v' matched '%v' unexpectedly, matched %v chars. \n", (i+1), ntests, pattern, text, length)
                nfailed += 1
            }
        }
        else
        {
            if m == (-1)
            {
                fmt.printf("\n")
                re_print(re_compile(pattern));
                fmt.printf("[%v/%v]: pattern '%v' didn't match '%v' as expected. \n", (i+1), ntests, pattern, text)
                nfailed += 1
            }
            else if (length != correctlen)
            {
                fmt.printf("[%v/%v]: pattern '%v' matched '%v' chars of '%v'; expected '%v'. \n", (i+1), ntests, pattern, length, text, correctlen)
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