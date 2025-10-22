#include <assert.h>
#include <limits.h>
#include <stdio.h>
#include <unistd.h>

#include <config.hh>
#include <controller.hh>
#include <emit.hh>
#include <registerallocator.hh>
#include <syscall-wrappers.hh>
#include <utils.h>

#include <libgen.h>
#include <unistd.h>


Controller *controller;
Config *config;
CibylElf *elf;

static void usage() {
  printf(
      "\nUsage: xcibyl-translator config:<...> dst-dir elf-file "
      "syscall-database...\n"
      "\n"
      "Where config is the configuration to use, dst-dir is the destination\n"
      "directory to put translated files in, elf-file the input MIPS binary "
      "file,\n"
      "syscall-database is one or more cibyl-syscalls.db files. The config "
      "options\n"
      "are:\n\n"

      "   trace_start=0x...       The first address of instruction tracing\n"
      "   trace_end=0x...         The last address of instruction tracing\n"
      "   trace_stores=0/1        Set to 1 to trace memory stores\n"
      "   thread_safe=0/1         Set to 1 to generate thread-safe code "
      "(default 0)\n"
      "   class_size_limit=N      Set the size limit for classes (class split "
      "size)\n"
      "   call_table_hierarchy=N  Generate a call table hierarchy with N "
      "methods (default 1)\n"
      "   call_table_classes=N    Generate several call table classes\n"
      "   prune_call_table=0/1    Set to 1 to prune unused indirect function "
      "calls\n"
      "   optimize_partial_memory_operations=0/1  Set to 1 to generate "
      "subroutine calls for\n"
      "                           lb/lh/sb/sh (default 0)\n"
      "   prune_unused_functions=0/1  Prune unused functions from the call "
      "table\n"
      "   colocate_functions=FN1;FN2;... Colocate functions FN1... in a single "
      "method\n"
      "   package_name=NAME       Set Java package name (default: unnamed)\n");
  exit(1);
}

static void parse_config(Controller *cntr, Config *cfg,
                         const char *config_str) {
  char *cpy = xstrdup(config_str);
  char *p;

  /* A series of "trace_start=0x12414,trace_end=0x15551,..." No spaces */
  p = strtok(cpy, ",");
  while (p) {
    char *value = strstr(p, "=");
    char *endp;
    int int_val;

    if (!value || strlen(value) < 2)
      usage();
    value[0] = '\0'; /* p is now the key */
    value++;         /* And value points to the value */

    int_val = strtol(value, &endp, 0);
    if (endp == value) {
      int_val = -1;
    }

    /* Now match the keys*/
    if (strcmp(p, "trace_start") == 0)
      cfg->traceRange[0] = int_val;
    else if (strcmp(p, "trace_end") == 0)
      cfg->traceRange[1] = int_val;
    else if (strcmp(p, "trace_stores") == 0)
      cfg->traceStores = int_val == 0 ? false : true;
    else if (strcmp(p, "thread_safe") == 0)
      cfg->threadSafe = int_val == 0 ? false : true;
    else if (strcmp(p, "prune_call_table") == 0)
      cfg->optimizeCallTable = int_val == 0 ? false : true;
    else if (strcmp(p, "optimize_partial_memory_operations") == 0)
      cfg->optimizePartialMemoryOps = int_val == 0 ? false : true;
    else if (strcmp(p, "optimize_prune_stack_stores") == 0)
      cfg->optimizePruneStackStores = int_val == 0 ? false : true;
    else if (strcmp(p, "optimize_function_return_arguments") == 0)
      cfg->optimizeFunctionReturnArguments = int_val == 0 ? false : true;
    else if (strcmp(p, "prune_unused_functions") == 0)
      cfg->pruneUnusedFunctions = int_val == 0 ? false : true;
    else if (strcmp(p, "class_size_limit") == 0)
      cfg->classSizeLimit = int_val;
    else if (strcmp(p, "call_table_hierarchy") == 0)
      cfg->callTableHierarchy = int_val;
    else if (strcmp(p, "call_table_classes") == 0)
      cfg->callTableClasses = int_val;
    else if (strcmp(p, "colocate_functions") == 0)
      cntr->addColocation(value);
    else if (strcmp(p, "package_name") == 0)
      cntr->setPackageName(value);
    else
      usage();

    p = strtok(NULL, ",");
  }

  if (cfg->traceRange[1] < cfg->traceRange[0]) {
    fprintf(stderr, "Trace start is after trace end!\n");
    usage();
  }

  free(p);
}

int main(int argc, const char **argv) {
  const char **defines = (const char **)xcalloc(argc, sizeof(const char *));
  int n, n_defines = 0;

  if (argc < 5) {
    fprintf(stderr, "Too few arguments\n");

    usage();
    return 1;
  }
  if (!strstr(argv[1], "config:")) {
    fprintf(stderr, "Error: expecting configuration first in argument list\n");
    usage();
  }
  /* Setup configuration */
  config = new Config();

  /* Setup defines */
  for (n = 2; n < argc && strncmp(argv[n], "-D", 2) == 0; n++) {
    defines[n_defines++] = argv[n];
  }

  emit = new Emit();

  regalloc = new RegisterAllocator();
  controller = new Controller(argv[0], defines, argv[n], argv[n + 1],
                              argc - n - 2, &argv[n + 2]);
  parse_config(controller, config, argv[1] + strlen("config:"));

  controller->pass0();
  controller->pass1();
  controller->pass2();

  return 0;
}
