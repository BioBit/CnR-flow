#!/usr/bin/env nextflow
//Daniel Stribling
//Renne Lab, University of Florida
//
//Pipeline Created/Updated: 2020-07-30

//This file is part of CnR-Flow.

//CnR-Flow is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.

//CnR-Flow is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.

//You should have received a copy of the GNU General Public License
//along with CnR-Flow.  If not, see <https://www.gnu.org/licenses/>.


// Step Settings:
params.do_merge_lanes = true
params.do_fastqc      = true
params.do_trim        = true
params.do_retrim      = true
params.do_norm_spike  = true
params.use_aln_modes  = ["all"] // Options: "all", "all_dedup", "less_120", "less_120_dedup"
params.peak_callers   = ['macs', 'seacr'] // Options: 'macs', 'seacr'

// Run Settings:
params.publish_files = 'default' // Options: "minimal", "default", "all"
params.publish_mode  = 'copy'    // Options: "symlink", "copy"

// Tool & Module Execution Settings:
// -- External Tools:
//params.bowtie2_module     = "bowtie2/2.3.5.1"
//params.fastqc_module      = "fastqc/0.11.7"
//params.trimmomatic_module = "trimmomatic/0.39"
//params.picard_module      = "picard/2.21.2"
//params.bedtools_module    = "bedtools/2.29.2"
//params.macs2_module       = "macs/2.2.7.1"
//params.R_module           = "R/4.0"

// -- Packaged Tools (Should not need additional dependencies):
//params.cutruntools_module  = ""
//params.kseqtest_module     = params.cutruntools_module //Should not be needed.
//params.filter_below_module = params.cutruntools_module //Should not be needed.
//params.seacr_module        = "${params.R_module}:${params.bedtools_module}"

// -- Comprehensive (If provided, is used for all execution)
//params.all_module         = ""

// System Call Settings
//   Can replace with direct path as desired:
//   Ex:
//        params.samtools_call = "samtools"
//     or params.samtools_call = "/path/to/samtools/dir/samtools" 
params.java_call           = "java"
params.bowtie2_build_call  = "bowtie2-build"
params.samtools_call       = "samtools"
params.faCount_call        = "${workflow.projectDir}/kent_utils/faCount"
params.fastqc_call         = "fastqc"
params.trimmomatic_call    = "trimmomatic"
params.kseqtest_call       = "kseq_test"
params.bowtie2_call        = "bowtie2"
params.filter_below_script = "${workflow.projectDir}/CUTRUNTools/filter_below.awk"
params.picard_call         = "picard"
params.bedtools_call      = "bedtools"
params.macs2_call         = "macs2"
params.seacr_call         = "${workflow.projectDir}/SEACR/SEACR_1.3.sh"
params.seacr_R_script     = "${workflow.projectDir}/SEACR/SEACR_1.3.R"
// -- Options with Explicit Java Usage:
//params.fastqc_call        = "fastqc --java ${params.java_call}"
//params.trimmomatic_call   = "${params.java_call} -jar /path/to/trimmomatic-0.??.jar"
//params.picard_call        = "${params.java_call} -jar /path/to/picard.jar"


// Step-Specific Analysis Parameters:
//params.trim_adapterpath = ''

//params.retrim_seq_len = ''

params.aln_ref_flags   = ("--local --very-sensitive-local --phred33 -I 10 -X 700 "
                          + "--dovetail --no-unal --no-mixed --no-discordant")
//params.aln_ref = ""
//params.aln_ref_name    = file(params.aln_ref, checkIfExists: false).getSimpleName()

params.aln_norm_flags  = params.aln_ref_flags
//params.aln_norm_flags = "--phred33 -I 10 -X 700 --no-dovetail --no-unal --no-mixed --no-discordant --no-overlap"
params.norm_scale      = 1000
params.norm_ref        = "${workflow.projectDir}/ref_dbs/ecoli_asm584v2/bt2_db/gcf_000005845.2_asm584v2_genomic"
params.norm_ref_name   = "ecoli_gcf_000005845"
params.norm_mode       = 'adj' // Options: 'adj' (default), 'all'

//params.macs_genome_size     = 3200000
params.macs_qval            = "0.01"

params.seacr_fdr_threshhold = "0.01"
params.seacr_norm_mode      = "auto" // Options: "auto", "norm", "non"
params.seacr_call_stringent = true
params.seacr_call_relaxed   = true

// CnR Input Files:
//Provided fastqs must be in glob pattern matching pairs.
// Example: ./my/base*R{1,2}*.fastq
//params.treat_fastqs = [] // Single-group Treatment fastq Pattern
//params.ctrl_fastqs  = [] // Single-group Control fastq pattern

//Can specify multiple treat/control groups as Groovy mapping.
//Note: There should be only one ctrl sample per group (after optional lane combination)
//Example:
//params.fastq_groups = [
//  'group_1_name': ['treat': 'path/to/treat1*R{1,2}*',
//                   'ctrl':  'path/to/ctrl1*R{1,2}*',
//                  ]
//  'group_2_name': ['treat': ['path/to/g2_treat1*R{1,2}*'
//                             '/other/path/to/g2_treat2*R{1,2}*'
//                            ],
//                   'ctrl':  'path/to/g2_ctrl1*R{1,2}*'
//                  ]
//]


//Name trim guide: 
//   ~/groovy-slashy-string/ 
//   "~" denotes groovy pattern type.
//   ~/^/ matches beginning
//   ~/$/ matches end
params.trim_name_prefix = '' // Example: ~/^myprefix./ removes "myprefix." prefix.
params.trim_name_suffix = '' // Example: ~/_mysuffix$/ removes "_mysuffix" suffix.   

// CnR Naming Scheme:
params.out_dir           = "${launchDir}/cnr_output"
params.refs_dir          = "${launchDir}/cnr_references"
params.log_dirn          = 'logs'
params.merge_fastqs_dirn = 'S0_A__merged_reads'
params.fastqc_pre_dir   = 'S0_B__FastQC_pre'
params.trim_dir         = 'S1_A__fastq_trimomatic'
params.retrim_dir       = 'S1_B__fastq_kseqtest'
params.fastqc_post_dir  = 'S1_C__FastQC_post'
params.aln_dir_ref      = 'S2_A1_aln_ref'
params.aln_dir_spike    = 'S2_A2_aln_spikein'
params.aln_dir_mod      = 'S2_B__aln_mod'
params.aln_dir_bdg      = 'S2_C__aln_bdg'
params.aln_dir_norm     = 'S2_D__aln_norm'
params.peaks_dir_macs   = 'S3_A1_peaks_macs'
params.peaks_dir_seacr  = 'S3_A2_peaks_seacr'
params.prep_bt2db_suf   = 'bt2_db'

// --------------- Setup Default Pipe Variables: ---------------
params.verbose = false
params.help = false
params.h = false
params.version = false
params.v = false
params.out_front_pad = 4
params.out_prop_pad = 17

// --------------- Check (and Describe) "--mode" param: ---------------
    //params.mode='run' //DEBUG
    modes = ['initiate', 'validate', 'validate_all', 'prep_fasta',
             'list_refs', 'dry_run', 'run', 'help', 'version']
    usage = """\
    USAGE:
        nextflow [NF_OPTIONS] run /rennelab/CnR-flow --mode <run-mode> [PIPE_OPTIONS]
        /path/to/${workflow.manifest.mainScript} [NF_OPTIONS] --mode <run-mode> [PIPE_OPTIONS]

    Run Modes:
        initiate     : Copy configuration templates to current directory
        validate     : Validate current dependency configuration
        validate_all : Validate all dependencies
        prep_fasta   : Prepare alignment reference from <genome>.fa[sta]
        list_refs    : List prepared alignment references
        dry_run      : Check configruation and all inputs, but don't run pipeline
        run          : Run pipeline
        help         : Print help and usage information for pipeline
        version      : Print pipeline version
    """

    help_description = """\
    ${workflow.manifest.name} Nextflow Pipeline, Version: ${workflow.manifest.version}
    This nextflow pipeline analyzes paired-end data in .fastq[.gz] format 
    created from CUT&RUN Experiments.

    """.stripIndent()
    full_help = help_description + "\n" + usage    
    full_version = " -- ${workflow.manifest.name} : ${workflow.manifest.mainScript} "
    full_version += ": ${workflow.manifest.version}"  

if( params.containsKey('mode') && params.mode == 'prep_all' ) { params.mode = 'prep' }

if( params.help || params.h ) {
    println full_help
    exit 0
} else if( params.version || params.v ) {
    println full_version
    exit 0
} else if( !params.containsKey('mode') ) {
    println ""
    log.warn "--mode Keyword ('params.mode) not provided." 
    log.warn "Use --h, --help, --mode=help, or --mode help  for more information."
    log.warn "Defaulting to --mode='dry_run'"
    log.warn ""
    params.mode = 'dry_run'
} else if( !modes.any{it == params.mode} ) {
    println ""
    log.error "Unrecognized --mode Keyword ('params.mode):"
    log.error "    '${params.mode}'"
    log.error ""
    println usage
    exit 1
} else if( params.mode == 'help' ) {
    println full_help
    exit 0
} else if( params.mode == 'version' ) {
    println full_version
    exit 0
} else {
    log.info ""
    log.info "Utilizing Run Mode: ${params.mode}"
}

print_in_files = []

// If mode is 'prep_fasta', ensure "ref_fasta" has been provided.
if( ['prep_fasta'].contains(params.mode) ) {
    if( !file("${params.ref_fasta}", checkIfExists: false).exists() ) {
        message = "File for reference preparation does not exist:\n"
        message += "    gnome_sequence: ${params['ref_fasta']}\n"
        message += check_full_file_path(params['ref_fasta'])
        log.error message
        exit 1
    }
}

// If a run or validate mode, ensure all required keys have been provided correctly.
if(['run', 'dry_run', 'validate', 'validate_all'].contains(params.mode) ) {
    // Check to ensure required keys have been provided correctly.
    first_test_keys = [
        'do_merge_lanes', 'do_fastqc', 'do_trim', 'do_retrim', 'do_norm_spike', 
        'peak_callers', 'java_call', 'bowtie2_build_call', 'samtools_call',
        'faCount_call',
        'fastqc_call', 'trimmomatic_call', 'kseqtest_call', 'bowtie2_call', 
        'picard_call', 'filter_below_script', 'bedtools_call', 'macs2_call', 
        'seacr_call', 'out_dir', 'refs_dir', 'log_dirn', 'prep_bt2db_suf',
        'merge_fastqs_dirn', 'fastqc_pre_dir', 'trim_dir', 'retrim_dir',
        'fastqc_post_dir', 'aln_dir_ref', 'aln_dir_spike', 'aln_dir_mod',
        'aln_dir_norm', 'peaks_dir_macs', 'peaks_dir_seacr',
        'verbose', 'help', 'h', 'version', 'v', 'out_front_pad', 'out_prop_pad', 
        'trim_name_prefix', 'trim_name_suffix'
    ]
    first_test_keys.each { test_params_key(params, it) } 
    use_tests = []
    req_keys = []
    req_files = []

    test_commands = [
        "Java": ["${params.java_call} -version", 0, *get_resources(params, 'java')],
        "bowtie2-build": ["${params.bowtie2_build_call} --version", 0, 
            *get_resources(params, 'bowtie2')],
        "Samtools": ["${params.samtools_call} help", 0, *get_resources(params, 'samtools')],
        "FastQC": ["${params.fastqc_call} -v", 0, *get_resources(params, 'fastqc')], 
        "Trimmomatic": ["${params.trimmomatic_call} -version", 0, *get_resources(params, 'trimmomatic')],
        "kseqtest": ["${params.kseqtest_call}", 1, *get_resources(params, 'kseqtest') ],
        "bowtie2": ["${params.bowtie2_call} --version", 0, *get_resources(params, 'bowtie2')],
        "Picard": ["${params.picard_call} SortSam -h", 1, *get_resources(params, 'picard')],
        "filter_below": ["[ -f ${params.filter_below_script} ]", 0, *get_resources(params, 'filter_below')],
        "bedtools": ["${params.bedtools_call} --version", 0, *get_resources(params, 'bedtools')],
        "MACS2": ["${params.macs2_call} --version", 0, *get_resources(params, 'macs2')],
        "SEACR": ["${params.seacr_call}", 1, *get_resources(params, 'seacr')],
    ] 

    // General Keys and Params:
    req_keys.add(['publish_files', ['minimal', 'default', 'all']])
    req_keys.add(['publish_mode', ['symlink', 'copy']])

    // Keys and Params for merging langes
    if( params.do_merge_lanes ) {
        null//No custom settings
    }
    // Keys and Params for FastQC
    if( params.do_fastqc ) {
        use_tests.add(["FastQC", *test_commands["FastQC"]])
    }
    // Keys and Params for Trimmomatic trimming
    if( params.do_trim ) {
        use_tests.add(["Trimmomatic", *test_commands["Trimmomatic"]])
        req_files.add(['trim_adapterpath'])
    }
    // Keys and Params for Trimmomatic trimming
    if( params.do_retrim ) {
        use_tests.add(["kseqtest", *test_commands["kseqtest"]])
        req_keys.add(['retrim_seq_len'])
    }
    // keys and params for alignment steps
    if( true ) {
        use_tests.add(["bowtie2", *test_commands["bowtie2"]])
        use_tests.add(["Samtools", *test_commands["Samtools"]])
        use_tests.add(["Picard", *test_commands["Picard"]])
        use_tests.add(["filter_below", *test_commands["filter_below"]])
        use_tests.add(["bedtools", *test_commands["bedtools"]])
        req_keys.add(['aln_ref'])
        req_keys.add(['aln_ref_name'])
        req_keys.add(['aln_ref_flags'])
        req_keys.add(['use_aln_modes',
            ['all', 'all_dedup', 'less_120', 'less_120_dedup']])
        req_files.add(['chrom_sizes'])
    }
    // keys and params for normalization
    if( params.do_norm_spike ) {
        req_keys.add(['norm_scale'])
        req_keys.add(['norm_ref'])
        req_keys.add(['norm_ref_name'])
        req_keys.add(['norm_mode', ['adj', 'all']])
    }
    // keys and params for peak calling
    req_keys.add(['peak_callers', ['macs', 'seacr']])
    if( params.peak_callers.contains('macs') ) {
        use_tests.add(["MACS2", *test_commands["MACS2"]])
        req_keys.add(['macs_qval'])
        req_keys.add(['macs_genome_size'])
    }
    if( params.peak_callers.contains('seacr') ) {
        use_tests.add(["SEACR", *test_commands["SEACR"]])
        req_keys.add(['seacr_fdr_threshhold'])
        req_keys.add(['seacr_norm_mode', ['auto', 'norm', 'non']])
        req_keys.add(['seacr_call_stringent', [true, false]])
        req_keys.add(['seacr_call_relaxed', [true, false]])
    }

    // If validate_all, ignore prepared tests and test all dependencies.
    if( params.mode == 'validate_all' ) {
        use_tests = []
        test_commands.each{test -> use_tests.add([test.key, *test.value]) }
    }

    // If a Run Mode, Test Step-Specific Keys and Required Files:
    if( ['run', 'dry_run'].contains(params.mode) ) {
        test_params_keys(params, req_keys)
        test_params_files(params, req_files) 
    }
}

// If run mode, ensure input files have been provided and test existence.
if( ['run', 'dry_run'].contains(params.mode) ) {
    if( params.containsKey('treat_fastqs') && params.containsKey('fastq_groups') ) {
        message =  "Please provide input fastq file data to either of \n"
        message += "    --treat_fastqs  (params.treat_fastqs)\n"
        message += " or --fastq_groups  (params.fastq_groups)\n"
        message += "    (not both)\n"
        log.error message
        exit 1
    // If Input files are via params.treat_fastqs
    } else if( params.containsKey('treat_fastqs') ) { 
        if( !params.treat_fastqs ) {
            err_message = "params.treat_fastqs cannot be empty if provided."
            log.error err_message
            exit 1
        }
        // Check Existence of treat and control fastqs if provided.
        if( params.treat_fastqs instanceof List ) {
            params.treat_fastqs.each{it -> print_in_files.addAll(file(it, checkIfExists: true)) }
        } else {
            print_in_files.addAll(file(params.treat_fastqs, checkIfExists: true))
        }
        if( params.containsKey('ctrl_fastqs') ) {
            if( params.ctrl_fastqs instanceof List ) {
                params.ctrl_fastqs.each{it -> print_in_files.addAll(file(it, checkIfExists: true)) }
            } else {
                print_in_files.addAll(file(params.ctrl_fastqs, checkIfExists: true))
            }
        }
    
    // If Input files are via params.fastq_groups
    } else if( params.containsKey('fastq_groups') ) {
        if( !params.fastq_groups ) {
            err_message = "params.fastq_groups cannot be empty if provided."
            log.error err_message
            exit 1
        }
        params.fastq_groups.each {group_name, group_details ->
            if( !group_details.containsKey('treat') || !group_details.treat ) {
                err_message =  "params.fastq_groups - Group: '${group_name}\n"
                err_message += "    Does not contain required key 'treat' or variable is empty."
                log.error err_message
                exit 1
            }
            if( !group_details.containsKey('ctrl') || !group_details.ctrl ) {
                warn_message =  "params.fastq_groups - Group: '${group_name}\n"
                warn_message += "    Does not contain key 'ctrl' or variable is empty.\n\n"
                warn_message += "(If this is intentional, please consider using '--treat_fastqs\n'"
                warn_message += "    parameter instead for file input as this may produce \n"
                warn_message += "    unexpected output)"
                log.warn warn_message
            }
            if( group_details.treat instanceof List ) {
                group_details.treat.each{it -> print_in_files.addAll(file(it, checkIfExists: true)) }
            } else {
                print_in_files.addAll(file(group_details.treat, checkIfExists: true)) 
            }
            if( group_details.containsKey('ctrl') ) {
                if( group_details.ctrl instanceof List ) {
                    group_details.ctrl.each{it -> 
                        print_in_files.addAll(file(it, checkIfExists: true))
                    }
                } else {
                    print_in_files.addAll(file(group_details.ctrl, checkIfExists: true)) 
                }
            }
        }
    }
}

use_aln_modes = return_as_list(params['use_aln_modes'])
peak_callers  = return_as_list(params['peak_callers'])

// --------------- If Verbose, Print Nextflow Command: ---------------
if( params.verbose ) { print_command(workflow.commandLine) }

// --------------- Parameter Setup ---------------
log.info ''
log.info ' -- Preparing Workflow Environment -- '
log.info ''

// --------------- Print Workflow Details ---------------

// If Verbose, Print Workflow Details:
if( params.verbose ) {
    print_workflow_details(workflow, params, params.out_front_pad, params.out_prop_pad)
}

// -- If a Run Mode, Check-for and Print Input Files
if( ['run', 'dry_run'].contains( params.mode) ) {
    if( print_in_files.size() < 2 ) {
        message =  "No Input Files Provided.\n"
        message += "Please provide valid --treat_fastqs (params.treat_fastqs) option.\n"
        message += "   Exiting"
        log.error message
        exit 1

    } else if( params.verbose ) {
        message = (
                   "-".multiply(params.out_front_pad)
                   + "Input Files:".padRight(params.out_prop_pad)
                   + print_in_files[0] 
                  )
        log.info message
        print_in_files.subList(1, print_in_files.size()).each {
    
            log.info "-".multiply(params.out_front_pad) + ' '.multiply(params.out_prop_pad) + it
        }
    } else {
        log.info "${print_in_files.size()} Input Files Detected. "
    }
}

// --------------- Execute Workflow ---------------

log.info ''
log.info ' -- Executing Workflow -- '
log.info ''
System.out.flush(); System.err.flush()

// -- Run Mode: validate
if( ['validate', 'validate_all'].contains( params.mode ) ) { 
    process CR_ValidateCall {
        tag             { title }
        // Previous step ensures only one or another (non-null) resource is provided:
        module          { "${test_module}" }
        conda           { "${test_conda}" }
        executor        'local'
        maxForks        1
        errorStrategy   'terminate'
        cpus            1
        echo            true

        input:
        tuple val(title), val(test_call), val(exp_code), val(test_module), val(test_conda) from Channel.fromList(use_tests)
        
        output:
        val('success') into validate_outs

        script:
        resource_string = ''
        if( task.module) { 
            resource_string = "echo -e '  -  Module(s): ${task.module.join(':')}'"
        } else if( task.conda) {
            resource_string = "echo -e '  -  Conda-env: \"${task.conda.toString()}\"'"
        }
        
        shell:
        '''
        echo -e "\\n!{task.tag}"
        !{resource_string}
        echo -e "\\nTesting System Call for dependency: !{title}"
        echo -e "Using Command:"
        echo -e "    !{test_call}\\n"

        set +e
        !{test_call}
        TEST_EXIT_CODE=$?
        set -e

        if [ "${TEST_EXIT_CODE}" == "!{exp_code}" ]; then
            echo "!{title} Test Success."
            PROCESS_EXIT_CODE=0
        else
            echo "!{title} Test Failure."
            echo "Exit Code: ${TEST_EXIT_CODE}"
            PROCESS_EXIT_CODE=${TEST_EXIT_CODE}
        fi
        exit ${PROCESS_EXIT_CODE} 
        '''
    }
    validate_outs
                .collect()
                .view { it -> "\nDependencies Have been Validated, Results:\n    $it\n" } 

}

// -- Run Mode: prep_fasta
if( params.mode == 'prep_fasta' ) { 
    if( "${params.ref_fasta}".endsWith('.gz') ) {
        temp_name = file("${params.ref_fasta}").getBaseName()
        db_name = file("${temp_name}").getBaseName()
    } else {
        db_name = file("${params.ref_fasta}").getBaseName()
    }
    Channel.fromPath("${params.ref_fasta}")
          .map {full_fn -> [db_name, full_fn] }
          .set {source_fasta}

    process CR_getFasta {
        tag         { name }
        stageInMode 'copy'    
        echo        true

        input:
        tuple val(name), path(fasta) from source_fasta
    
        output:
        tuple val(name), path(use_fasta) into get_fasta_outs
        val get_fasta_details into get_fasta_detail_outs
        path '.command.log' into get_fasta_log_outs
    
        publishDir "${params.refs_dir}/logs", mode: params.publish_mode, 
                   pattern: ".command.log", saveAs: { out_log_name }
        publishDir "${params.refs_dir}", mode: params.publish_mode, 
                   overwrite: false, pattern: "${use_fasta}*"
    
        script:
        run_id         = "${task.tag}.${task.process}"
        out_log_name   = "${run_id}.nf.log.txt"
        task_details   = task_details(task)
        full_refs_dir  = "${params.refs_dir}"
        if( !(full_refs_dir.startsWith("/")) ) {
            full_refs_dir = "${workflow.launchDir}/${params.refs_dir}"
        }
        if( "${fasta}".endsWith('.gz') ) {
            use_fasta = fasta.getBaseName()  
            gunzip_command = "gunzip -c ${fasta} > ${use_fasta}"
        } else {
            use_fasta = fasta
            gunzip_command = "echo 'File is not gzipped.'"
        }
        get_fasta_details  = "name,${name}\n"
        get_fasta_details += "title,${name}\n"
        get_fasta_details += "fasta_path,${full_refs_dir}/${use_fasta}"

        shell:
        task_details + '''
    
        echo "Acquiring Fasta from Source:"
        echo "    !{fasta}"
        echo ""
        !{gunzip_command}

        echo "Publishing Fasta to References Directory:"
        echo "   !{full_refs_dir}"    
    
        '''
    }

    get_fasta_outs.into{prep_bt2db_inputs; prep_sizes_inputs}

    process CR_PrepBt2db {
        if( has_module(params, 'bowtie2') ) {
            module get_module(params, 'bowtie2')
        } else if( has_conda(params, 'bowtie2') ) {
            conda get_conda(params, 'bowtie2')
        }
        tag  { name }
        echo true
    
        input:
        tuple val(name), path(fasta) from prep_bt2db_inputs
    
        output:
        path "${bt2db_dir_name}/*" into prep_bt2db_outs
        val bt2db_details into prep_bt2db_detail_outs
        path '.command.log' into prep_bt2db_log_outs
    
        publishDir "${params.refs_dir}/logs", mode: params.publish_mode, 
                   pattern: ".command.log", saveAs: { out_log_name }
        publishDir "${params.refs_dir}", mode: params.publish_mode, 
                   pattern: "${bt2db_dir_name}/*"
    
        script:
        run_id         = "${task.tag}.${task.process}"
        out_log_name   = "${run_id}.nf.log.txt"
        task_details   = task_details(task)
        bt2db_dir_name = "${name}_${params.prep_bt2db_suf}"
        refs_dir       = "${params.refs_dir}"
        full_out_base  = "${bt2db_dir_name}/${name}"
        bt2db_details  = "bt2db_path,./${full_out_base}"
        shell:
        task_details + '''
    
        echo "Preparing Bowtie2 Database for fasta file:"
        echo "    !{fasta}"
        echo ""
        echo "Out DB Dir: !{bt2db_dir_name}"
        echo "Out DB:     !{full_out_base}"

        mkdir -v !{bt2db_dir_name}
        set -v -H -o history
        !{params.bowtie2_build_call} --threads !{task.cpus} !{fasta} !{full_out_base}
        set +v +H +o history

        echo "Publishing Bowtie2 Database to References Directory:"
        echo "   !{params.refs_dir}"    
    
        '''
    }
    
    process CR_PrepSizes {
        if( has_module(params, 'samtools') ) {
            module get_module(params, 'samtools')
        } else if( has_conda(params, 'samtools') ) {
            conda get_conda(params, 'samtools')
        }
        tag  { name }
        cpus 1
        echo true
    
        input:
        tuple val(name), path(fasta) from prep_sizes_inputs
    
        output:
        tuple path(faidx_name), path(chrom_sizes_name), path(fa_count_name),
              path(eff_size_name) into prep_sizes_outs
        val prep_sizes_details into prep_sizes_detail_outs
        path '.command.log' into prep_sizes_log_outs
    
        publishDir "${params.refs_dir}/logs", mode: params.publish_mode, 
                   pattern: ".command.log", saveAs: { out_log_name } 
        publishDir "${params.refs_dir}", mode: params.publish_mode, 
                   pattern: "${name}*" 
    
        script:
        run_id = "${task.tag}.${task.process}"
        out_log_name = "${run_id}.nf.log.txt"
        task_details = task_details(task)
        faidx_name = "${fasta}.fai"
        chrom_sizes_name = "${name}.chrom.sizes"
        fa_count_name = "${name}.faCount"
        eff_size_name = "${name}.effGenome"
        prep_sizes_details  = "faidx_path,./${faidx_name}\n"
        prep_sizes_details += "chrom_sizes_path,./${chrom_sizes_name}\n"
        prep_sizes_details += "fa_count_path,./${fa_count_name}\n"
        prep_sizes_details += "effective_genome_path,./${eff_size_name}"
        shell:
        task_details + '''
        echo -e "\\nPreparing genome size information for Input Fasta: !{fasta}"
        echo -e "Indexing Fasta..."
        !{params.samtools_call} faidx !{fasta}
        echo -e "Preparing '.chrom.sizes' File..."
        cut -f1,2 !{faidx_name} > !{chrom_sizes_name}
        echo -e "Counting Reference Nucleotides..."
        !{params.faCount_call} !{fasta} > !{fa_count_name}
        echo -e "Calculating Reference Effective Genome Size (Total - N's method )..."
        TOTAL=$(tail -n 1 !{fa_count_name} | cut -f2) 
        NS=$(tail -n 1 !{fa_count_name} | cut -f7)
        EFFECTIVE=$( bc <<< "${TOTAL} - ${NS}")
        echo "${EFFECTIVE}" > !{eff_size_name}
        echo "Effective Genome Size: ${TOTAL} - ${NS} = ${EFFECTIVE}"
        echo "Done."
        '''
    }

    get_fasta_detail_outs
                        .concat(prep_sizes_detail_outs)
                        .concat(prep_bt2db_detail_outs)
                        .collectFile(name: "${params.refs_dir}/${db_name}.refinfo.txt", newLine: true, sort: false)
                        .view { "Database Prepared and published in:\n    ${params.refs_dir}\n\nDetails:\n${it.text}" }

}

// -- Run Mode: 'dry_run'
if( params.mode == 'dry_run' ) {
    process CRDryRun {
        tag  { "my_input" }
        echo true
    
        output:
        path "${test_out_file_name}" into dryRun_outs
        path '.command.log' into dryRun_log_outs
    
        publishDir "${params.out_dir}/${params.log_dirn}", mode: params.publish_mode, 
                   pattern: ".command.log", saveAs: { out_log_name } 
        publishDir "${params.out_dir}", mode: params.publish_mode, 
                   pattern: "${test_out_file_name}"
    
        when:
        params.mode == 'dry_run'
    
        script:
        run_id = "${task.tag}.${task.process}"
        out_log_name = "${run_id}.nf.log.txt"
        test_out_file_name = "test_out_file.txt"
        task_details = task_details(task)
        shell:
        '''
        echo -e "\\Current parameters for a \\"!{(task.label ?: ['non-labeled']).join(', ')}\\" job:"
        ''' + task_details + '''
        echo "Performing 'Dry Run' Test:"
    
        echo "Would Execute Pipeline now."
    
        echo "Creating Test Out File: !{test_out_file_name}"
        echo "Dry Run Test Output File Created on: $(date)" > !{test_out_file_name}
    
        echo -e "\\n\\"Dry Run\\" test complete.\\n"
        '''
    }
}

// -- Run Mode: 'run'
if( params.mode == 'run' ) { 
    use_ctrl_samples = false
    // If Input files are via params.treat_fastqs
    if( params.containsKey('treat_fastqs') ) { 
        Channel.fromFilePairs(params.treat_fastqs)
              .map {name, fastqs -> [name, 'treat', 'main', fastqs] }
              .set { treat_fastqs }
        //Create Channel of Control Fastas, if existing.
        if( params.containsKey('ctrl_fastqs') && params.ctrl_fastqs ) { 
            Channel.fromFilePairs(params.ctrl_fastqs)
                  .map {name, fastqs -> [name, 'ctrl', 'main', fastqs] }
                  .set { ctrl_fastqs } 
            use_ctrl_samples = true
            if( params.verbose ) {
                log.info "Control Samples Detected. Enabling Treatment/Control Peak-Calling Mode."
                log.info ""
            }
        } else {
            Channel.empty()
                  .set { ctrl_fastqs }
            use_ctrl_samples = false
            if( params.verbose ) {
                log.info "No Control Samples Detected."
                log.info ""
            }
            
        }
    // If Input files are via params.fastq_groups
    } else if( params.containsKey('fastq_groups') ) {
        treat_channels = []
        ctrl_channels = []
        params.fastq_groups.each {group_name, group_details ->
            treat_channels.add(
                Channel
                      .fromFilePairs(group_details.treat, checkIfExists: true)
                      .map {name, fastqs -> [name, 'treat', group_name, fastqs] }
                )

            if( group_details.containsKey('ctrl') ) {
                if( !use_ctrl_samples ) {
                    use_ctrl_samples = true
                    if( params.verbose ) {
                        log.info "Control Samples Detected. Enabling Treatment/Control Peak-Calling Mode."
                        log.info ""
                }
            }

                ctrl_channels.add(
                    Channel
                          .fromFilePairs(group_details.ctrl, checkIfExists: true)
                          .map {name, fastqs -> [name, 'ctrl', group_name, fastqs] }
                )
            }
        }
        Channel.empty()
              .mix(*treat_channels)
              .set { treat_fastqs }
        Channel.empty()
              .mix(*ctrl_channels)
              .set { ctrl_fastqs }
    }

    // Mix (Labeled) Treatment and Control Fastqs
    ctrl_fastqs
          .concat( treat_fastqs )
          // Remove duplicate ctrl also matched as treat:
          .unique { name, cond, group, fastqs -> name }
          .map { name, cond, group, fastqs ->
                 // Remove "_R" name suffix
                 name = name - ~/_R$/
                 [name, cond, group, fastqs]
               }
          .set { prep_fastqs }

    // If Merge, combine sample prefix-duplicates and catenate files.
    if( params.do_merge_lanes ) {
        prep_fastqs
                  // Remove "_L00?" name suffix
                  .map { name, cond, group, fastqs ->
                         name = name - ~/_L00\d$/ 
                         name = name - params.trim_name_prefix
                         name = name - params.trim_name_suffix
                         [name, cond, group, fastqs]
                       }
                  // Group files by common name
                  .groupTuple()
                  // Reformat grouped files so that fastqs are in lists of pairs.
                  .map {name, conds, groups, fastq_pairs ->
                        [name, conds[0], groups[0], fastq_pairs.flatten()]
                       }
                  .set { merge_fastqs } 
        
        // Step 0, Part A, Merge Lanes (If Enabled)
        process CR_S0_A__MergeFastqs {
            tag  { name }
            cpus 1
           
            input:
            tuple val(name), val(cond), val(group), path(fastq) from merge_fastqs
        
            output:
            tuple val(name), val(cond), val(group), path("${merge_fastqs_dir}/${name}_R{1,2}_001.fastq.gz") into use_fastqs
            path '.command.log' into mergeFastqs_log_outs
        
            publishDir "${params.out_dir}/${params.log_dirn}", mode: params.publish_mode, 
                       pattern: '.command.log', saveAs: { out_log_name } 
            // Publish merged fastq files only when publish_files == all
            publishDir "${params.out_dir}", mode: params.publish_mode,
                       pattern: "${merge_fastqs_dir}/*", 
                       enabled: (params.publish_files == "all") 
        
            script:
            run_id = "${task.tag}.${task.process}"
            out_log_name = "${run_id}.nf.log.txt"
            task_details = task_details(task)
            merge_fastqs_dir = "${params.merge_fastqs_dirn}"
            R1_files = fastq.findAll {fn -> "${fn}".contains("_R1_") }
            R2_files = fastq.findAll {fn -> "${fn}".contains("_R2_") }
            R1_out_file = "${params.merge_fastqs_dirn}/${name}_R1_001.fastq.gz"
            R2_out_file = "${params.merge_fastqs_dirn}/${name}_R2_001.fastq.gz" 

            if( R1_files.size() == 1 && R2_files.size() == 1 ) {
                command = '''
                echo "No Merge Necessary. Renaming Files..."
                set -v -H -o history
                mv -v "!{R1_files[0]}" "!{R1_out_file}"
                mv -v "!{R2_files[0]}" "!{R2_out_file}"
                set +v +H +o history
                '''.stripIndent()
            } else {
                command = '''
                mkdir !{merge_fastqs_dir}
                echo -e "\\nCombining Files: !{R1_files.join(' ')}"
                echo "    Into: !{R1_out_file}"
                set -v -H -o history
                cat '!{R1_files.join("' '")}' > '!{R1_out_file}'
                set +v +H +o history
    
                echo -e "\\nCombining Files: !{R2_files.join(' ')}"
                echo "    Into: !{R2_out_file}"
                set -v -H -o history
                cat '!{R2_files.join("' '")}' > '!{R2_out_file}'
                set +v +H +o history
                '''.stripIndent()
            }
            shell:
            task_details + command

        }
    // If Not Merge, Rename and Passthrough fastq files.
    } else {
        prep_fastqs
                  .map { name, cond, group, fastqs ->
                         name = name - params.trim_name_prefix
                         name = name - params.trim_name_suffix
                         [name, cond, group, fastqs]
                       }
                  .set { use_fastqs }
    }

    // Prepare Step 0/1 Input Channels
    use_fastqs.into { fastqcPre_inputs; trim_inputs } 

    
    // Step 0, Part B, FastQC Analysis (If Enabled)
    if( params.do_fastqc ) {
        process CR_S0_B__FastQCPre {
            if( has_module(params, 'fastqc') ) {
                module get_module(params, 'fastqc')
            } else if( has_conda(params, 'fastqc') ) {
                conda get_conda(params, 'fastqc')
            }
            tag { name }
        
            input:
            tuple val(name), val(cond), val(group), path(fastq) from fastqcPre_inputs
        
            output:
            path "${fastqc_out_dir}/*.{html,zip}" into fastqcPre_all_outs
            path '.command.log' into fastqcPre_log_outs
        
            publishDir "${params.out_dir}/${params.log_dirn}", mode: params.publish_mode, 
                       pattern: '.command.log', saveAs: { out_log_name } 
            publishDir "${params.out_dir}", mode: params.publish_mode, 
                       pattern: "${fastqc_out_dir}/*"
        
            script:
            run_id = "${task.tag}.${task.process}"
            out_log_name = "${run_id}.nf.log.txt"
            task_details = task_details(task)
            fastqc_out_dir = params.fastqc_pre_dir
            shell:
            task_details + '''
        
            set -v -H -o history
            mkdir -v !{fastqc_out_dir}
            cat !{fastq} > !{name}_all.fastq.gz
            !{params.fastqc_call} -t !{task.cpus} -o !{fastqc_out_dir} !{name}_all.fastq.gz
            set +v +H +o history
            '''.stripIndent()
        }
    }


    // Step 01, Part A, Trim Reads using Trimmomatic (if_enabled)
    if( params.do_trim ) {
        process CR_S1_A__Trim { 
            if( has_module(params, 'trimmomatic') ) {
                module get_module(params, 'trimmomatic')
            } else if( has_conda(params, 'trimmomatic') ) {
                conda get_conda(params, 'trimmomatic')
            }
            tag { name }
        
            input:
            tuple val(name), val(cond), val(group), path(fastq) from trim_inputs
        
            output:
            path "${params.trim_dir}/*" into trim_all_outs
            tuple val(name), val(cond), val(group), path("${params.trim_dir}/*.paired.*") into trim_outs
            path '.command.log' into trim_log_outs
        
            // Publish Log
            publishDir "${params.out_dir}/${params.log_dirn}", mode: params.publish_mode, 
                       pattern: '.command.log', saveAs: { out_log_name }
            // Publish if publish_mode == 'all', or == 'default' and not last trim step.
            publishDir "${params.out_dir}", mode: params.publish_mode,
                       pattern: "${params.trim_dir}/*.paired.*",
                       enabled: (
                           (params.publish_files == "default" && !params.do_retrim)
                            || params.publish_files == "all"
                       )
        
            script:
            run_id = "${task.tag}.${task.process}"
            out_log_name = "${run_id}.nf.log.txt"
            task_details = task_details(task)
        
            shell:
            task_details + '''
            mkdir !{params.trim_dir}
            echo "Trimming file name base: !{name} ... utilizing Trimmomatic"

            set -v -H -o history
            !{params.trimmomatic_call} PE \\
                          -threads !{task.cpus} \\
                          -phred33 \\
                          !{fastq} \\
                          !{params.trim_dir}/!{name}_1.paired.fastq.gz !{params.trim_dir}/!{name}_1.unpaired.fastq.gz \\
                          !{params.trim_dir}/!{name}_2.paired.fastq.gz !{params.trim_dir}/!{name}_2.unpaired.fastq.gz \\
                          ILLUMINACLIP:!{params.trim_adapterpath}/Truseq3.PE.fa:2:15:4:4:true \\
                          LEADING:20 TRAILING:20 SLIDINGWINDOW:4:15 MINLEN:25
            set +v +H +o history

            echo "Step 01, Part A, Trimmomatic Trimming, Complete."
            '''.stripIndent()
        }
    // If not performing trimming, pass trim output to retrim channel.
    } else {
        trim_inputs.set { trim_outs } 
    }

    // Step 01, Part B, Retrim Sequences Using Cut&RunTools kseq_test (If Enabled)
    if( params.do_retrim ) {
        process CR_S1_B__Retrim { 
            if( has_module(params, 'kseqtest') ) {
                module get_module(params, 'kseqtest')
            } else if( has_conda(params, 'kseqtest') ) {
                conda get_conda(params, 'kseqtest')
            }
            tag  { name }
            cpus 1   
     
            input:
            tuple val(name), val(cond), val(group), path(fastq) from trim_outs
        
            output:
            tuple val(name), val(cond), val(group), path("${params.retrim_dir}/*") into trim_final
            path '.command.log' into retrim_log_outs
        
            // Publish Log
            publishDir "${params.out_dir}/${params.log_dirn}", mode: params.publish_mode, 
                       pattern: '.command.log', saveAs: { out_log_name }
            // Publish if publish_files == "all" or "default"
            publishDir "${params.out_dir}", mode: params.publish_mode, 
                       pattern: "${params.retrim_dir}/*",
                       enabled: (
                           params.publish_files == "all" 
                           || params.publish_files == 'default'
                       )
        
            script:
            run_id = "${task.tag}.${task.process}"
            out_log_name = "${run_id}.nf.log.txt"
            task_details = task_details(task)
            seq_len = params.retrim_seq_len
        
            shell:
            task_details + '''
            mkdir !{params.retrim_dir}
            echo "Second stage (retrimming) name base: !{name} ... utilizing kseq_test ..."

            set -v -H -o history
            !{params.kseqtest_call} !{fastq[0]} !{seq_len} \\
                                    !{params.retrim_dir}/!{fastq[0]}
        
            !{params.kseqtest_call} !{fastq[1]} !{seq_len} \\
                                    !{params.retrim_dir}/!{fastq[1]}
            set +v +H +o history        

            echo "Step 01, Part B, kseq_test Trimming, Complete."
            '''.stripIndent()
        }
    // If not performing retrimming, pass trim output onto alignments.
    } else {
        trim_outs.set { trim_final }
    }

    trim_final.into { fastqcPost_inputs; aln_ref_inputs; aln_spike_inputs }

    // Step 01, Part C, Evaluate Final Trimmed Sequences With FastQC (If Enabled)
    if( params.do_fastqc ) {
        process CR_S1_C__FastQCPost {
            if( has_module(params, 'fastqc') ) {
                module get_module(params, 'fastqc')
            } else if( has_conda(params, 'fastqc') ) {
                conda get_conda(params, 'fastqc')
            }
            tag { name }
           
            input:
            tuple val(name), val(cond), val(group), path(fastq) from fastqcPost_inputs
        
            output:
            path "${fastqc_out_dir}/*.{html,zip}" into fastqcPost_all_outs
            path '.command.log' into fastqcPost_log_outs
        
            publishDir "${params.out_dir}/${params.log_dirn}", mode: params.publish_mode, 
                       pattern: '.command.log', saveAs: { out_log_name } 
            publishDir "${params.out_dir}", mode: params.publish_mode, 
                       pattern: "${fastqc_out_dir}/*"
        
            script:
            run_id = "${task.tag}.${task.process}"
            out_log_name = "${run_id}.nf.log.txt"
            task_details = task_details(task)
            fastqc_out_dir = params.fastqc_post_dir 
            shell:
            task_details + '''
        
            set -v -H -o history
            mkdir -v !{fastqc_out_dir}
            cat !{fastq} > !{name}_all.fastq.gz
            fastqc -t !{task.cpus} -o !{fastqc_out_dir} !{name}_all.fastq.gz
            set +v +H +o history
            '''.stripIndent()
        }
    }

    // Step 02, Part A1, Align Reads to Reference Genome(s)
    process CR_S2_A1_Aln_Ref {
        if( has_module(params, ['bowtie2', 'samtools']) ) {
            module get_module(params, ['bowtie2', 'samtools'])
        } else if( has_conda(params, ['bowtie2', 'samtools']) ) {
            conda get_conda(params, ['bowtie2', 'samtools'])
        }
        tag { name }
    
        input:
        tuple val(name), val(cond), val(group), path(fastq) from aln_ref_inputs
    
        output:
        tuple val(name), val(cond), val(group), path("${params.aln_dir_ref}/*") into aln_outs
        path '.command.log' into aln_log_outs
    
        // Publish Log
        publishDir "${params.out_dir}/${params.log_dirn}", mode: params.publish_mode, 
                   pattern: '.command.log', saveAs: { out_log_name }
        // Publish unsorted alignments only when publish_files == all
        publishDir "${params.out_dir}", mode: params.publish_mode, 
                   pattern: "${params.aln_dir_ref}/*",
                   enabled: (params.publish_files == "all")
    
        script:
        run_id = "${task.tag}.${task.process}"
        out_log_name = "${run_id}.nf.log.txt"
        task_details = task_details(task)
        aln_ref_flags = params.aln_ref_flags
        aln_ref = params.aln_ref
    
        shell:
        task_details + '''
        set -o pipefail
        mkdir !{params.aln_dir_ref}
        echo "Aligning file name base: !{name} ... utilizing Bowtie2"
    
        set -v -H -o history
        !{params.bowtie2_call} -p !{task.cpus} \\
                               !{aln_ref_flags} \\
                               -x !{aln_ref} \\
                               -1 !{fastq[0]} \\
                               -2 !{fastq[1]} \\
                                 | !{params.samtools_call} view -bS - \\
                                   > !{params.aln_dir_ref}/!{name}.bam
        set +v +H +o history

        echo "Step 02, Part A, Alignment, Complete."
        '''.stripIndent()
    }
    // Step 02, Part A2, Align Reads to Spike-In Genome (If Enabled)
    if( params.do_norm_spike ) {
        process CR_S2_A2_Aln_Spike {
            if( has_module(params, ['bowtie2', 'samtools']) ) {
                module get_module(params, ['bowtie2', 'samtools'])
            } else if( has_conda(params, ['bowtie2', 'samtools']) ) {
                conda get_conda(params, ['bowtie2', 'samtools'])
            }
            tag { name }
        
            input:
            tuple val(name), val(cond), val(group), path(fastq) from aln_spike_inputs
        
            output:
            path "${params.aln_dir_spike}/*" into aln_spike_all_outs
            tuple val(name), path(aln_count_csv) into aln_spike_csv_outs
            tuple val(name), path(aln_spike_count) into aln_spike_outs
            path '.command.log' into aln_spike_log_outs
        
            // Publish Log
            publishDir "${params.out_dir}/${params.log_dirn}", mode: params.publish_mode, 
                       pattern: '.command.log', saveAs: { out_log_name }
            // Publish count file if publish_file == "minimal" or "default"
            publishDir "${params.out_dir}", mode: params.publish_mode, 
                       pattern: "${aln_use_count}",
                       enabled:  (params.publish_files != "all") 
            // Publish report if publish_file == "default"
            publishDir "${params.out_dir}", mode: params.publish_mode, 
                       pattern: "${aln_count_report}",
                       enabled: (params.publish_files == "default")
            // Publish all files when publish_files == all
            publishDir "${params.out_dir}", mode: params.publish_mode, 
                       pattern: "${params.aln_dir_spike}/*",
                       enabled: (params.publish_files == "all")
        
            script:
            run_id = "${task.tag}.${task.process}"
            out_log_name = "${run_id}.nf.log.txt"
            task_details = task_details(task)
            spike_ref        = params.norm_ref
            spike_ref_name   = params.norm_ref_name
            aln_ref          = params.aln_ref
            aln_ref_name     = params.aln_ref_name
            aln_norm_flags   = params.aln_norm_flags
            aln_spike_sam    = "${params.aln_dir_spike}/${name}.${spike_ref_name}.sam"
            aln_spike_fq     = "${params.aln_dir_spike}/${name}.${spike_ref_name}.fastq.gz"
            aln_spike_fq_1   = "${params.aln_dir_spike}/${name}.${spike_ref_name}.fastq.1.gz"
            aln_spike_fq_2   = "${params.aln_dir_spike}/${name}.${spike_ref_name}.fastq.2.gz"
            aln_cross_sam    = "${params.aln_dir_spike}/${name}.cross.${aln_ref_name}.sam"
            aln_count        = "${params.aln_dir_spike}/${name}.${spike_ref_name}.count_report"
            aln_count_report = "${params.aln_dir_spike}/${name}.${spike_ref_name}.count_report.txt" 
            aln_count_csv    = "${params.aln_dir_spike}/${name}.${spike_ref_name}.count_report.csv" 
            aln_spike_count  = "${params.aln_dir_spike}/${name}.${spike_ref_name}.01.all.count.txt"
            aln_cross_count  = "${params.aln_dir_spike}/${name}.${spike_ref_name}.02.cross.count.txt"
            aln_adj_count    = "${params.aln_dir_spike}/${name}.${spike_ref_name}.03.adj.count.txt"
            if( params.norm_mode == 'adj') { 
                aln_use_count = aln_adj_count
            } else if( params.norm_mode == 'all' ) {
                aln_use_count = aln_spike_count
            }

            if( fastq[0].toString().endsWith('.gz') ) {
                count_command = 'echo "$(zcat ' + "${fastq[0]}" + ' | wc -l)/4" | bc'
            } else {
                count_command = 'echo "$(wc -l ' + "${fastq[0]}" + ')/4" | bc'
            }
            shell:
            task_details + '''
            set -o pipefail
            mkdir !{params.aln_dir_spike}
            echo "Aligning file name base: !{name} ... utilizing Bowtie2"

            # Count Total Read Pairs
            PAIR_NUM="$(!{count_command})"
            MESSAGE="Counted ${PAIR_NUM} Fastq Read Pairs."
            echo -e "\\n${MESSAGE}\\n"
            echo    "${MESSAGE}" > !{aln_count_report}

            # Align Reads to Spike-in Genome
            set -v -H -o history
            !{params.bowtie2_call} -p !{task.cpus} \\
                                   !{aln_norm_flags} \\
                                   -x !{spike_ref} \\
                                   -1 !{fastq[0]} \\
                                   -2 !{fastq[1]} \\
                                   -S !{aln_spike_sam} \\
                                   --al-conc-gz !{aln_spike_fq}
                                          
            RAW_SPIKE_COUNT="$(!{params.samtools_call} view -Sc !{aln_spike_sam})"
            bc <<< "${RAW_SPIKE_COUNT}/2" > !{aln_spike_count}
            SPIKE_COUNT=$(cat !{aln_spike_count})
            SPIKE_PERCENT=$(bc -l <<< "scale=8; (${SPIKE_COUNT}/${PAIR_NUM})*100")
          
            set +v +H +o history

            MESSAGE="${SPIKE_COUNT} ( ${SPIKE_PERCENT}% ) Total Spike-In Read Pairs Detected"
            echo -e "\\n${MESSAGE}\\n"
            echo    "${MESSAGE}" >> !{aln_count_report}

            # Realign Spike-in Alignments to Reference Genome to Check Cross-Mapping
            set -v -H -o history
            !{params.bowtie2_call} -p !{task.cpus} \\
                                   !{aln_norm_flags} \\
                                   -x !{aln_ref} \\
                                   -1 !{aln_spike_fq_1} \\
                                   -2 !{aln_spike_fq_2} \\
                                   -S !{aln_cross_sam}

            RAW_CROSS_COUNT="$(!{params.samtools_call} view -Sc !{aln_cross_sam})"
            bc <<< "${RAW_CROSS_COUNT}/2" > !{aln_cross_count}
            CROSS_COUNT=$(cat !{aln_cross_count})
            set +v +H +o history

            MESSAGE="${CROSS_COUNT} Read Pairs Detected that Cross-Map to Reference Genome"
            echo -e "\\n${MESSAGE}\\n"
            echo    "${MESSAGE}" >> !{aln_count_report}
         
            # Get Difference Between All Spike-In and Cross-Mapped Reads
            OPERATION="${SPIKE_COUNT} - ${CROSS_COUNT}"
            bc <<< "${OPERATION}" > !{aln_adj_count}  
            ADJ_COUNT=$(cat !{aln_adj_count})
            ADJ_PERCENT=$(bc -l <<< "scale=8; (${ADJ+COUNT}/${PAIR_NUM})*100")

            MESSAGE="$(cat !{aln_adj_count}) (${OPERATION}, ${ADJ_PERCENT}) Adjusted Spike-in Reads Detected."
            echo -e "\\n${MESSAGE}\\n"
            echo    "${MESSAGE}" >> !{aln_count_report}

            MESSAGE="\\nNormalization Mode: !{params.norm_mode}\\n"
            MESSAGE+="Selecting file for use in sample normalization:\\n"
            MESSAGE+="    !{aln_use_count}"
            echo -e "\\n${MESSAGE}\\n"
            echo -e "${MESSAGE}" >> !{aln_count_report}

            echo -e "name,fq_pairs,spike_aln_pairs,spike_aln_pct,cross_aln_pairs,cross_aln_pct,adj_aln_pairs,adj_aln_pct" > !{aln_count_csv}
            echo -e "!{name},${PAIR_NUM},${SPIKE_COUNT},${SPIKE_PERCENT},${CROSS_COUNT},CROSS_PCT,${ADJ_COUNT},${ADJ_PERCENT}" >> !{aln_count_csv}
 

            echo "Step 02, Part A2, Spike-In Alignment, Complete."
            '''.stripIndent()
        }

    //aln_spike_csv_outs


    }

    // Step 02, Part B, Sort and Process Alignments
    process CR_S2_B__Modify_Aln {
        if( has_module(params, ['picard', 'samtools']) ) {
            module get_module(params, ['picard', 'samtools'])
        } else if( has_conda(params, ['picard', 'samtools']) ) {
            conda get_conda(params, ['picard', 'samtools'])
        }
        tag { name }
    
        input:
        tuple val(name), val(cond), val(group), path(aln) from aln_outs
    
        output:
        path "${params.aln_dir_mod}/*" into sort_aln_all_outs
        tuple val(name), val(cond), val(group), val("all"), 
              path("${params.aln_dir_mod}/${name}_sort_dm.*") into sort_aln_outs_all
        tuple val(name), val(cond), val(group), val("all_dedup"), 
              path("${params.aln_dir_mod}/${name}_sort_dm_dedup.*") into sort_aln_outs_all_dedup
        tuple val(name), val(cond), val(group), val("limit_120"), 
              path("${params.aln_dir_mod}/${name}_sort_dm_120.*") into sort_aln_outs_120
        tuple val(name), val(cond), val(group), val("limit_120_dedup"), 
              path("${params.aln_dir_mod}/${name}_sort_dm_dedup_120.*") into sort_aln_outs_120_dedup
        path '.command.log' into sort_aln_log_outs
    
        // Publish Log
        publishDir "${params.out_dir}/${params.log_dirn}", mode: params.publish_mode, 
                   pattern: '.command.log', saveAs: { out_log_name }
        // If publish raw alingments only if publish_files == "all",
        publishDir "${params.out_dir}", mode: params.publish_mode, 
                   pattern: "${params.aln_dir_mod}/*",
                   enabled: (params.publish_files=="all")
    
        //when:
        //params.mode == 'run'
        
        script:
        run_id              = "${task.tag}.${task.process}"
        out_log_name        = "${run_id}.nf.log.txt"
        aln_dir_mod         = "${params.aln_dir_mod}"
        aln_sort            = "${aln_dir_mod}/${name}_sort.bam"
        aln_sort_dm         = "${aln_dir_mod}/${name}_sort_dm.bam"
        aln_sort_dedup      = "${aln_dir_mod}/${name}_sort_dm_dedup.bam"
        aln_sort_120        = "${aln_dir_mod}/${name}_sort_dm_120.bam"
        aln_sort_dedup_120  = "${aln_dir_mod}/${name}_sort_dm_dedup_120.bam"
        dedup_metrics       = "${aln_dir_mod}/${name}.dedup_metrics.txt"
        task_details = task_details(task)
        add_threads = (task.cpus ? (task.cpus - 1) : 0) 
    
        shell:
        task_details + '''
    
        echo ""
        set -o pipefail
        mkdir -v !{aln_dir_mod}
        
        echo ""
        echo "Filtering Unmapped Fragments for name base: !{name} ... utilizing Samtools View"
    
        set -v -H -o history
        !{params.samtools_call} view -bh -f 3 -F 4 -F 8 --threads !{add_threads} !{aln} > !{aln_sort}.step1.bam
        set +v +H +o history

        echo ""
        echo "Sorting BAM for name base: !{name} ... utilizing Picard SortSam"

        set -v -H -o history
        !{params.picard_call} SortSam \\
        INPUT=!{aln_sort}.step1.bam \\
        OUTPUT=!{aln_sort} \\
        SORT_ORDER=coordinate \\
        VALIDATION_STRINGENCY=SILENT
        rm -rfv !{aln_sort}.step1.bam
        set +v +H +o history

        echo ""
        echo "Marking Duplicates for name base: !{name} ... utilizing Picard MarkDuplicates"

        set -v -H -o history
        !{params.picard_call} MarkDuplicates \\
        INPUT=!{aln_sort} \\
        OUTPUT=!{aln_sort_dm} \\
        VALIDATION_STRINGENCY=SILENT \\
        METRICS_FILE=!{dedup_metrics}
        set +v +H +o history
        
        echo ""
        echo "Removing Duplicates for name base: !{name} ... utilizing Samtools view"

        set -v -H -o history
        !{params.samtools_call} view -bh -F 1024 --threads !{add_threads} !{aln_sort_dm} > !{aln_sort_dedup}
        set +v +H +o history
    
        echo ""
        echo "Filtering Non-Deduplicated Alignments for name base: !{name} ... to < 120 utilizing Samtools view"
       
 
        set -v -H -o history
        !{params.samtools_call} view -h --threads !{add_threads} !{aln_sort_dm} \\
            |LC_ALL=C awk -f !{params.filter_below_script} \\
            |!{params.samtools_call} view -Sb --threads !{add_threads} - \\
            > !{aln_sort_120}
        set +v +H +o history

        echo ""
        echo "Filtering Deduplicated Alignments for name base: !{name} ... to < 120 utilizing Samtools view"
    
        set -v -H -o history
        !{params.samtools_call} view -h --threads !{add_threads} !{aln_sort_dedup} \\
            |LC_ALL=C awk -f !{params.filter_below_script} \\
            |!{params.samtools_call} view -Sb --threads !{add_threads} - \\
            > !{aln_sort_dedup_120}
        set +v +H +o history
        
        echo ""
        echo "Creating bam index files for name base: !{name} ... utilizing Samtools index"

        set -v -H -o history
        !{params.samtools_call} index !{aln_sort}
        !{params.samtools_call} index !{aln_sort_dm}
        !{params.samtools_call} index !{aln_sort_dedup}
        !{params.samtools_call} index !{aln_sort_120}
        !{params.samtools_call} index !{aln_sort_dedup_120}
        set +v +H +o history

        echo "Step 02, Part B, (Sort -> Dedup -> Filter) Alignments, Complete."
        '''.stripIndent()
    }
      
    use_aln_channels = []
    if( use_aln_modes.contains('all') ) {
        use_aln_channels.add(sort_aln_outs_all)
    }
    if( use_aln_modes.contains('all_dedup') ) {
        use_aln_channels.add(sort_aln_outs_all_dedup)
    }
    if( use_aln_modes.contains('less_120') ) {
        use_aln_channels.add(sort_aln_outs_120)
    }
    if( use_aln_modes.contains('less_120_dedup') ) {
        use_aln_channels.add(sort_aln_outs_120_dedup)
    }

    if( use_aln_channels.size() < 1 ) {
        log.error "No Valid Alignment Channels Enabled."
        log.error params.use_aln_channels
        exit 1
    } else if ( use_aln_channels.size() > 1 ) { 
        use_aln_channels[0]
            .mix(*(use_aln_channels.subList(1, use_aln_channels.size())))
            .set { use_mod_alns }
    } else {
        use_aln_channels[0]
            .set { use_mod_alns }
    }

    //Channel.empty()
    //      .mix(sort_aln_outs_all)
    //      .mix(sort_aln_outs_all_dedup)
    //      .mix(sort_aln_outs_120)
    //      .mix(sort_aln_outs_120_dedup)
    //      .filter {name, cond, group, mode, alns -> params.use_aln_modes.contains(mode) }
    //      .set { use_mod_alns }

    // Step 02, Part C, Create Paired-end Bedgraphs
    process CR_S2_C__Make_Bdg {
        if( has_module(params, ['samtools', 'bedtools']) ) {
            module get_module(params, ['samtools', 'bedtools'])
        } else if( has_conda(params, ['samtools', 'bedtools']) ) {
            conda get_conda(params, ['samtools', 'bedtools'])
        }
        tag { name }
    
        input:
        tuple val(name), val(cond), val(group), val(aln_type), path(aln) from use_mod_alns
    
        output:
        path "${aln_dir_bdg}/*" into bdg_aln_all_outs
        tuple val(name), val(cond), val(group), val(aln_type), 
              path("${aln_dir_bdg}/*.{bam,bdg,frag}*", includeInputs: true ) into bdg_aln_outs

        path '.command.log' into bdg_aln_log_outs
    
        // Publish Log
        publishDir "${params.out_dir}/${params.log_dirn}", mode: params.publish_mode, 
                   pattern: '.command.log', saveAs: { out_log_name }
        // Publish Bedgraph if publish_files == "default" or "minimal" and no normalization.
        publishDir "${params.out_dir}", mode: params.publish_mode, 
                   pattern: "${aln_dir_bdg}/*.bdg",
                   enabled: (
                       (params.publish_files == "minimal" && !params.do_norm_spike)
                       || (params.publish_files == "default")
                   )
        // Publish Coord-Sorted Bam Alignemnts if publish_files == "default"
        publishDir "${params.out_dir}", mode: params.publish_mode, 
                   pattern: "${aln_dir_bdg}/${aln_in}",
                   enabled: (params.publish_files=="default")
        // Publish All Outputs if publish_fiels == "all"
        publishDir "${params.out_dir}", mode: params.publish_mode, 
                   pattern: "${aln_dir_bdg}/*",
                   enabled: (params.publish_files=="all")
    
        
        script:
        run_id       = "${task.tag}.${task.process}.${aln_type}"
        out_log_name = "${run_id}.nf.log.txt"
        aln_dir_bdg  = "${params.aln_dir_bdg}.${aln_type}"
        aln_in       = "${aln[0]}"
        aln_in_base  = "${aln[0].getBaseName()}" 
        aln_by_name  = "${aln_dir_bdg}/${aln_in_base}_byname.bam"
        aln_bed      = "${aln_dir_bdg}/${aln_in_base + ".bed"}"
        aln_bdg      = "${aln_dir_bdg}/${aln_in_base + ".bdg"}"
        chrom_sizes  = "${params.chrom_sizes}"
        task_details = task_details(task)
        add_threads = (task.cpus ? (task.cpus - 1) : 0) 
    
        shell:
        task_details + '''
    
        echo ""
        mkdir -v !{aln_dir_bdg}
        cp -v !{aln_in} !{aln_dir_bdg}/!{aln_in}       

        echo "Sorting BAM File by name: !{aln_in} ... utilizing samtools sort"
        set -v -H -o history
        !{params.samtools_call} sort -n -O BAM -@ !{add_threads} \\
                                            -o !{aln_by_name} \\
                                            !{aln_in}

        set -v -H -o history
        echo ""
        echo "Convert Bam into Paired-end Bedgraph."
        echo "Procedure: https://github.com/FredHutch/SEACR/blob/master/README.md" 
        echo ""
        echo "Creating Bedgraph for file: !{aln_by_name} ... utilizing bamtools bamtobed"
         
        set -v -H -o history
        !{params.bedtools_call} bamtobed -bedpe -i !{aln_by_name} > !{aln_bed}
        set +v +H +o history

        echo ""
        echo "Modifying bed file file: !{aln_bed} ... utilizing awk, cut, and sort."
        set -v -H -o history
        awk '$1==$4 && $6-$2 < 1000 {print $0}' !{aln_bed} > !{aln_bed}.clean
        cut -f 1,2,6 !{aln_bed}.clean | sort -k1,1 -k2,2n -k3,3n > !{aln_bed}.clean.frag
        set +v +H +o history


        echo ""
        echo "Creating Bedgraph using bedtools genomecov."
        set -v -H -o history
        !{params.bedtools_call} genomecov -bg -i !{aln_bed}.clean.frag -g !{chrom_sizes} > !{aln_bdg}
        set +v +H +o history

        echo "Step 02, Part C, Convert (BAM -> BED -> BDG) Alignments, Complete."
        '''.stripIndent()
    }
    
    // Step 02, Part D, Normalize to Spike-in (If Enabled) Create Paired-end Bedgraphs
    if( params.do_norm_spike ) {

        aln_spike_outs
                  .cross(bdg_aln_outs)
                  .map {norm, samp -> 
                        [samp[0], samp[1], samp[2], samp[3], samp[4], norm[1]]
                  }
                  .set { norm_bdg_input }

        process CR_S2_D__Norm_Bdg {
            if( has_module(params, 'bedtools') ) {
                module get_module(params, 'bedtools')
            } else if( has_conda(params, 'bedtools') ) {
                conda get_conda(params, 'bedtools')
            }
            tag  { name }
            cpus 1        

            input:
            tuple val(name), val(cond), val(group), val(aln_type), path(aln), path(norm) from norm_bdg_input
        
            output:
            path "${aln_dir_norm}/*" into norm_all_outs
            tuple val(name), val(cond), val(group), val(aln_type), 
                  path("${aln_dir_norm}/*.{bam,bdg}*", includeInputs: true
                  ) into final_alns
            path '.command.log' into norm_log_outs
        
            // Publish Log
            publishDir "${params.out_dir}/${params.log_dirn}", mode: params.publish_mode, 
                       pattern: '.command.log', saveAs: { out_log_name }
            // Publish bedgraph if publish_files == "minimal" or "default"
            publishDir "${params.out_dir}", mode: params.publish_mode, 
                       pattern: "${aln_dir_norm}/*_norm.bdg",
                       enabled: (params.publish_files!="all")
            // Publish all outputs if publish_files == "all"
            publishDir "${params.out_dir}", mode: params.publish_mode, 
                       pattern: "${aln_dir_norm}/*",
                       enabled: (params.publish_files=="all") 
            
            script:
            run_id        = "${task.tag}.${task.process}.${aln_type}"
            out_log_name  = "${run_id}.nf.log.txt"
            chrom_sizes   = "${params.chrom_sizes}"
            task_details = task_details(task)
            aln_dir_norm  = "${params.aln_dir_norm}.${aln_type}"
            bed_frag      = "${aln[2]}"
            bed_frag_base = "${bed_frag - ~/.bed.clean.frag$/}" 
            norm_bdg      = "${aln_dir_norm}/${bed_frag_base + "_norm.bdg"}"
        
            shell:
            task_details + '''
        
            echo !{aln}
            echo ""
            mkdir -v !{aln_dir_norm}
            cp -v !{aln[0]} !{aln[2]} !{aln[3]} !{aln_dir_norm}           

            echo "Calculating Scaling Factor..."
            # Reference: https://github.com/Henikoff/Cut-and-Run/blob/master/spike_in_calibration.csh
            CALC="!{params.norm_scale}/$(cat !{norm})"
            SCALE=$(bc -l <<< "scale=8; $CALC")

            echo "Scaling factor caluculated: ( ${CALC} ) = ${SCALE} "

            echo ""
            echo "Creating normalized bedgraph using bedtools genomecov."
            set -v -H -o history
            !{params.bedtools_call} genomecov -bg -i !{bed_frag} -g !{chrom_sizes} -scale ${SCALE} > !{norm_bdg}
            set +v +H +o history

            echo "Step 02, Part D, Create Normalized Bedgraph, Complete."
            '''.stripIndent()
        }
    } else {
        bdg_aln_outs.set { final_alns }
    }

    // If Control Samples Provided, associate each per-group treat sample with
    //   its corresponding control sample.
    if( use_ctrl_samples ) {
        final_alns
                 //.view()
                 .branch {name, cond, group, mode, alns -> 
                     ctrl: cond == "ctrl"
                     treat: cond == "treat"
                 }
                 .set { cmb_aln_outs }   
    
        cmb_aln_outs.ctrl
                        .cross(cmb_aln_outs.treat) {name, cond, group, aln_set, alns -> "${group}.${aln_set}" }
                        .map {ctrl_info, treat_info ->
                              treat_name = treat_info[0]
                              treat_group = treat_info[2]
                              treat_aln_set = treat_info[3]
                              treat_alns = treat_info[4]
                              ctrl_name = ctrl_info[0]
                              ctrl_alns = ctrl_info[4]
                              [treat_name, treat_group, treat_aln_set, treat_alns, ctrl_name, ctrl_alns]
                        }
                        .into { macs_alns; seacr_alns }
    // If no control samples provided, remove "condition" and add ctrl placeholder variables
    } else {
        final_alns
                 .map {name, cond, group, aln_set, alns ->
                       [name, group, aln_set, alns, null, file("${workflow.projectDir}/templates/no_ctrl.txt")]
                 }
                 .into { macs_alns; seacr_alns }
    }

    //Channel.empty()
    //            .into { macs_alns; seacr_alns }   
 
    // Step 03, Part A, option 1, Utilize MACS for Peak Calling
    if( peak_callers.contains("macs") ) {
        process CR_S3_A__Peaks_MACS {
            if( has_module(params, 'macs2') ) {
                module get_module(params, 'macs2')
            } else if( has_conda(params, 'macs2') ) {
                conda get_conda(params, 'macs2')
            }
            tag { name }
        
            input:
            tuple val(name), val(cond), val(group), val(aln_type), path(aln) from macs_alns
        
            output:
            path "${peaks_dir}/*" into macs_peak_all_outs
            tuple val(name), val(cond), val(group), val(aln_type), 
                  path("${peaks_dir}/*") into macs_peak_outs
            path '.command.log' into macs_peak_log_outs
        
            // Publish Log
            publishDir "${params.out_dir}/${params.log_dirn}", mode: params.publish_mode, 
                       pattern: '.command.log', saveAs: { out_log_name }
            // Publish Only Minimal Outputs
            publishDir "${params.out_dir}", mode: params.publish_mode, 
                       pattern: "${peaks_dir}/*",
                       enabled: (params.publish_files!="all")
            // Publish All Outputs
            publishDir "${params.out_dir}", mode: params.publish_mode, 
                       pattern: "${peaks_dir}/*",
                       enabled: (params.publish_files!="all") 
            
            script:
            run_id        = "${task.tag}.${task.process}.${aln_type}"
            out_log_name  = "${run_id}.nf.log.txt"
            peaks_dir     = "${params.peaks_macs_dir}.${aln_type}"
            treat_bam     = "treat.bam"
            ctrl_bam      = "ctrl.bam"
            ctrl_flag     = "-c ${ctrl_bam}"
            qval          = "${params.macs_qval}"
            genome_size   = "${params.macs_genome_size}"
            keep_dup_flag = aln_type.contains('_dedup') ? "" : "--keep-dup all " 
            task_details = task_details(task)
            //add_threads = (task.cpus ? (task.cpus - 1) : 0) 
        
            shell:
            task_details + '''
        
            echo ""
            mkdir -v !{peaks_dir}
           
            echo "Calling Peaks for base name: !{name} ... utilizing macs2 callpeak"
             
            set -v -H -o history
            !{params.macs2_call} callpeak -f BAMPE -B --SPMR \\
                                              -t !{treat_bam} \\
                                              !{ctrl_flag} \\
                                              -g ${genome_size} \\
                                              -n !{name} \\
                                              --outdir !{peaks_dir} \\
                                              -q !{qval} \\
                                              !{keep_dup_flag}

            set +v +H +o history
    
            echo "Step 03, Part A, Call Peaks Using MACS, Complete."
            '''.stripIndent()
        }
    }

    // Step 03, Part A, option 2, Utilize MACS for Peak Calling
    if( peak_callers.contains("seacr") ) {
        process CR_S3_A__Peaks_SEACR {
            if( has_module(params, 'seacr') ) {
                module get_module(params, 'seacr')
            } else if( has_conda(params, 'seacr') ) {
                conda get_conda(params, 'seacr')
            }
            tag { name }
        
            input:
            tuple val(name), val(group), val(aln_type), path(aln), val(ctrl_name), path(ctrl_aln) from seacr_alns
        
            output:
            path "${peaks_dir}/*" into seacr_peak_all_outs
            tuple val(name), val(group), val(aln_type), 
                  path("${peaks_dir}/*.bed") into seacr_peak_outs
            path '.command.log' into seacr_peak_log_outs
        
            // Publish Log
            publishDir "${params.out_dir}/${params.log_dirn}", mode: params.publish_mode, 
                       pattern: '.command.log', saveAs: { out_log_name }
            // Publish All Outputs
            publishDir "${params.out_dir}", mode: params.publish_mode, 
                       pattern: "${peaks_dir}/*"
                       //enabled: (params.publish_files=="all") 
        
            
            script:
            run_id        = "${task.tag}.${task.process}.${aln_type}"
            out_log_name  = "${run_id}.nf.log.txt"
            task_details = task_details(task)
            peaks_dir     = "${params.peaks_dir_seacr}.${aln_type}"
            all_treat_bdg = aln.findAll {fn -> "${fn}".endsWith(".bdg") }
            treat_bdg     = all_treat_bdg[0]
            if( ctrl_name ) {
                all_ctrl_bdg = ctrl_aln.findAll {fn -> "${fn}".endsWith(".bdg") } 
                ctrl_flag = all_ctrl_bdg[0]
            } else {
                ctrl_flag = params.seacr_fdr_threshhold 
            }
            if( params.seacr_call_stringent && params.seacr_call_relaxed ) {
                do_relaxed   = "Enabled"
                do_stringent = "Enabled"
            } else if( params.seacr_call_relaxed ) {
                do_relaxed   = "Enabled"
                do_stringent = ""
            } else if( params.seacr_call_stringent ) {
                do_relaxed   = ""
                do_stringent = "Enabled"
            } else {
                throw new Exception("Need either stringent or relaxed modes enabled.")
            }
            if( params.seacr_norm_mode == 'auto' ) { 
                norm_mode = params.do_norm_spike ? 'non' : 'norm'
            } else {
                norm_mode = "${params.seacr_norm_mode}"
            }
            shell:
            task_details + '''
        
            echo ""
            mkdir -v !{peaks_dir}
           
            echo "Calling Peaks for base name: !{name} ... utilizing SEACR"
            set -v -H -o history
            if [ -n "!{do_relaxed}" ]; then

                echo 'Calling Peaks using "relaxed" mode.'
                !{params.seacr_call} !{treat_bdg} \\
                                     !{ctrl_flag} \\
                                     !{norm_mode} \\
                                     relaxed \\
                                     !{peaks_dir}/!{name}.!{aln_type}.peaks.seacr \\
                                     !{params.seacr_R_script} 
            fi

            if [ -n "!{do_stringent}" ]; then
                echo 'Calling Peaks using "stringent" mode.'
                !{params.seacr_call} !{treat_bdg} \\
                                     !{ctrl_flag} \\
                                     !{norm_mode} \\
                                     stringent \\
                                     !{peaks_dir}/!{name}.!{aln_type}.peaks.seacr \\
                                     !{params.seacr_R_script} 

            fi
            set +v +H +o history
    
            echo "Step 03, Part A2, Call Peaks Using SEACR, Complete."
            '''.stripIndent()
        }
    }

}
    

// --------------- Groovy Helper Functions ---------------
def return_as_list(item) {
    if( item instanceof List ) {
        item
    } else {
        [item]
    }
}

def get_resource_item(params, item_name, use_suffix, join_char, def_val="") {
    if( item_name instanceof List 
        && item_name.every {use_item -> params.containsKey(use_item + use_suffix) } ) {
        use_items = []
        item_name.each {use_item -> use_items.add(params[use_item + use_suffix])}
        ret_val = use_items.join(join_char)
    } else if( params.containsKey(item_name.toString() + use_suffix) ) { 
        ret_val = params[item_name + use_suffix]
    } else if( params.containsKey('all' + use_suffix) ) {
        ret_val = params['all' + use_suffix]
    } else {
        ret_val = def_val
    }
    ret_val
}
def get_module(params, name, def_val="") {
    get_resource_item(params, name, '_module', ':', def_val) 
}

def get_conda(params, name, def_val="") {
    get_resource_item(params, name, '_conda',  ' ', def_val)
}

def get_resources(params, name, def_val="") {
    use_module = get_module(params, name, def_val) 
    use_conda  = get_conda(params, name, def_val)
    if( use_module && use_conda ) {
        message =  "Both a '[item]_module' and a '[item]_conda' resource parameter provided "
        message += "for dependency/dependencies: ${name}\n"
        message += "    Module: ${use_module}\n"
        message += "    Conda:  ${use_conda}\n"
        message += "Please provide only one of these parameters.\n"  
        log.error message
        exit 1
    }
    [use_module, use_conda]
}

def has_module(params, name, def_val="") {
    use_module = get_resource_item(params, name, '_module', ':', def_val) 
    use_module != def_val
}

def has_conda(params, name, def_val="") {
    use_conda = get_resource_item(params, name, '_conda',  ' ', def_val)
    use_conda != def_val
}

//Return Boolean true if resources exist for name(s).
def has_resources(params, name) {
    resources = get_resources(params, name, def_val="")
    ( resources[0].toBoolean() || resources[1].toBoolean() )
}   


def test_params_key(params, key, allowed_opts=null) {
    if( !params.containsKey(key) ) {
        log.error "Required parameter key not provided:"
        log.error "    ${key}"
        log.error ""
        exit 1
    }
    if( allowed_opts ) { 
        value = params[key]
        if( value instanceof List) {
            value_list = value
        } else {
            value_list = [value]
        }
        value_list.each {
            if( !(allowed_opts.contains(it)) ) {
                log.error "Parameter: '${key}' does not contain an allowed option:"
                log.error "  Provided: ${it}"
                log.error "  Allowed:  ${allowed_opts}"
                log.error ""
                exit 1
            }
        }
    }
}             

def test_params_keys(params, test_keys) {
    test_keys.each{keyopts -> test_params_key(params, *keyopts) }
}

def test_params_file(params, test_file) {
    test_file = test_file[0]
    if( !params.containsKey(test_file) ) {
        log.error "Required file parameter key not provided:"
        log.error "    ${test_file}"
        log.error ""
        exit 1
    }
    this_file = file(params[test_file], checkIfExists: false)
    if( this_file instanceof List ) { this_file = this_file[0] }
    if( !this_file.exists() ) {
        log.error "Required file parameter '${test_file}' does not exist:"
        log.error check_full_file_path("${this_file}")
        exit 1
    }
} 

def test_params_files(params, test_files) {
    test_files.each{file_key -> test_params_file(params, file_key) }
}

def check_full_file_path(file_name) {
    out_message = "    ${file_name}\n"
    build_subpath = ""
    use_string = file_name - ~/^\// - ~/\/$/
    use_string.split('/').each { seg ->
        build_subpath += "/" + seg
        if( file(build_subpath, checkIfExists: false).exists() ) {
            out_message += "    Exists:         " + build_subpath + "\n"
        } else {
            out_message += "    Does not Exist: " + build_subpath + "\n"
        }
    }
    return out_message
}

def print_command ( command ) {
    log.info ""
    log.info "Nextflow Command:"
    log.info "    ${command}"    

    // If command is extensive, print individual parameter details..
    command_list = "${command}".split()
    if( command_list.size() > 5 ) {
        log.info ""
        log.info "Nextflow Command Details:"
        message = "    " + command_list[0]
        last_command = null
        [command_list].flatten().subList(1, command_list.size()).each {
            if( it == "run" ) {
                if( last_command != "--mode" ) { log.info message ; message = "   "}
                message += " run"
            } else if( it.startsWith('-') || it.startsWith('--') ) {
                log.info message
                message = "    $it"
            } else {
                message += " $it"
            }
            last_command = it 
        }
        log.info message
    }
}

def print_workflow_details(
        workflow = workflow,
        params = params, 
        front_pad = 4, 
        prop_pad = 17
    ) {

    if( params.verbose ) {
        log.info "-- Project Description:"
        log.info "${workflow.manifest.name} : ${workflow.manifest.version}"
        log.info "${workflow.manifest.description}"
    }

    print_config_files = "${workflow.configFiles[0]}"
    workflow.configFiles.subList(1, workflow.configFiles.size()).each {
      print_config_files = print_config_files.concat("\n".padRight(prop_pad) + it)
    }

    print_properties = [
        'NF Config Prof.': workflow.profile,
        'NF Script': workflow.scriptFile,
        'NF Launch Dir': workflow.launchDir,
        'NF Work Dir': workflow.workDir,
        'User': workflow.userName,
        'User Home Dir': workflow.homeDir,
        'Out Dir': params.out_dir,
        'Publish Files': params.publish_files,
        'Publish Mode': params.publish_mode,
        'Start Time': workflow.start,
    ]
    first_config = '-'.multiply(front_pad) 
    first_config += 'NF Config Files'.padRight(prop_pad) 
    first_config += "${workflow.configFiles[0]}"
    log.info first_config
    workflow.configFiles.subList(1, workflow.configFiles.size()).each {
      log.info '-'.multiply(front_pad) + ' '.multiply(prop_pad) + it
    }

    print_properties.each{key, value -> 
        log.info '-'.multiply(front_pad) + key.padRight(prop_pad) + value
    }
} 

def task_details(task, run_id='') {
    if( task.module ) { 
        resource_string = "Module(s): '${task.module.join(':')}'"
    } else if( task.conda ) {
        resource_string = "Conda-env: '${task.conda.toString()}'"
    } else {
        resource_string = 'Resources: None'
    }
    time_str  = ( "${task.time}" == "null" ? "" : "${task.time}" )
    mem_str   = ( "${task.memory}" == "null" ? "" : "${task.memory}" )
    queue_str = ( "${task.queue}" == "null" ? "" : "${task.queue}" )
    
    '''
    echo    "  !{run_id}"
    echo    "  -  Executor:  !{task.executor}"
    echo    "  -  CPUs:      !{task.cpus}"
    echo    "  -  Time:      !{time_str}"
    echo    "  -  Mem:       !{mem_str}"
    echo    "  -  Queue:     !{queue_str}"
    echo    "  -  !{resource_string}"
    echo -e "  -  Log:       !{out_log_name}\\n"
    '''.stripIndent()
}

sleep(4000)