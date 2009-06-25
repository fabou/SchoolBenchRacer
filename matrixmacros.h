#define new_matrix(n, m, type, M) \
	{\
	int i;\
	\
	M = malloc(n * sizeof(type *));\
		\
	for (i=0; i<n; i++)\
		M[i] = malloc(m * sizeof(type));\
	}\

#define copy_matrix(N, M, type, original, copy) \
{\
	int i,j;\
	for(i=0; i<N; i++)\
		for(j=0; j<N; j++)\
			copy[i][j] = original[i][j];\
}

#define free_matrix(N, M, matrix) \
{\
	int i;\
	for (i=0; i<N; i++)\
	free(matrix[i]);\
	free(matrix);\
}

#define dump_matrix(N, M, matrix) \
{\
	int i,j;\
	fprintf(stderr, "Matrix:\n");\
	fprintf(stderr, "T:\t");\
	for (j=0; j<M; j++)\
		fprintf(stderr, "%4i ", j);\
		fprintf(stderr, "\n");\
		fprintf(stderr, "\n");\
	for (i=0; i < N; i++){\
		fprintf(stderr, "Q:%i\t", i);\
		for (j=0; j<M; j++)\
			fprintf(stderr, "%4i ", matrix[i][j]);\
		fprintf(stderr, "\n");\
	}\
}

#define foreachij(N, M, matrix) \
				for(i=0; i<N; i++)\
					for(j=0; j<M; j++)\

#define dump_int_array(N, array) \
{ \
	int i; \
	for (i=0; i<N; i++){ \
		fprintf(stderr, "%i\t", i); \
		fprintf(stderr, "%i\n", array[i]); \
	} \
}
