#define STUB(a) static inline char a(void){\
    for(;;);\
}
STUB(argp_parse);
STUB(fts_close);
STUB(_obstack_free);