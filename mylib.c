#include <stdlib.h>
#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <limits.h>
#include <time.h>
#include <string.h>

#define min(x, y) ((x < y) ? x : y);
#define max(x, y) ((x < y) ? y : x);

char * slurp(FILE *fp){
/* Reads input into a char array which it returns. Input size limited by memory only.*/

/*After reading GROWBY bytes and filling the array, the function will request the system reserve GROWBY bytes of extra memory behind the end of the array, if that is not there, then the whole array is moved to an area with enough memory to hold the new size!
This will happen inputlength/GROWBY times, so ... can be slow*/

/*possible improvement: have it start with an array of size 1 and *multiply* (eg by 2) the size whenever it is full*/

	#define GROWBY 1000

	char *s = NULL;
	int c;
	int size = 0, capacity = 0, i = 0;	/*i: currently active character slot.*/

	while ((c=getc(fp)) != EOF){
		if (capacity <= 1){
			/*we need more character slots*/
			s = realloc(s, (size+GROWBY)*sizeof(char));
			size += GROWBY; capacity +=GROWBY;
		}
		s[i++] = c;
		capacity--;
	}
	if (s != NULL) s[i]='\0';
	return s;
}
#undef GROWBY

int RandFromInterval(int min, int max){
	/*Returns a random integer from [min, max].  Requires that 0 <= max-min < MAX_INT*/
	int x = 0;
	assert (max-min >= 0);

	x += min;
	x += rand() % (max-min+1);
	return x;
}

double drnd(void){
	/*Returns a random double from possible doubes in the interval [0,1]*/
	return (double)(rand()) / (double)RAND_MAX;
}

char * nextline(FILE *fp){
/* Returns a pointer to a character array containing the entire next line. The size of this array is n*50*sizeof(char) with n being the minimum required number.
Returns NULL on EOF.*/
	#define GROWBY 50
	char *s = NULL;
	int c;
	int size = 0, capacity = 0, i = 0;	/*i: currently active character slot.*/

	while ((c=getc(fp)) != EOF){
		if (capacity <= 1){
			/*we need more character slots*/
			s = (char *) realloc((void *) s, (size+GROWBY)*sizeof(char));
			size += GROWBY; capacity +=GROWBY;
		}
		s[i++] = c;
		capacity--;
		if (c=='\n') break;
	}
	if (s != NULL) s[i]='\0';
	return s;
}

char *chomp(char * line /*having an optional argument 'length' would not hurt*/){
	/*removes terminal \n from a string if present. O(length) time.*/
	int len;

	/*if length not specified*/ len = strlen(line);

	if (line[len-1] == '\n')
		line[len-1] = '\0';

	return line;
}

char *strdup(char * s){
	int len;
	char *r;

	len = strlen(s);
	r = malloc((len +1) * sizeof(char));

	strcpy(r, s);
	r[len] = '\0';
	return r;
}

/*-----not in use----*/

char *substring(char *first_letter, char *last_letter){
	/*returns a pointer to a substring of a char array, stretching from firstletter to lastletter. The substring ends with '\0'*/
	/*the substring is allocated its own memory and copied, which takes O(length of substring) time*/
	int len;
	char *curr_letter = first_letter;
	char *substr;

	len = max(0, last_letter - first_letter + 1);
	substr = calloc((len + 1), sizeof(char));

	while (curr_letter<=last_letter)
		substr[curr_letter - first_letter] = *(curr_letter++);

	substr[len] = '\0';

	return substr;
}

char *prefix(char *string, int length){
	if (length <= 0)
		return "\0";
	else
		return strncpy((char *)malloc(sizeof(char)*(length+1)), string, length);
}

double pr(double x){
	fprintf(stderr, " %f ", x);
	return x;
}

int strcmp_pointees(const void *pt_str1, const void *pt_str2){
	return strcmp(*(char **)pt_str1, *(char **)pt_str2);
}

