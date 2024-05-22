cases_path="/home/BCG2024_genomics_exam/"

recessive=false

# check empty case
if [ ${#@} == 0 ]; then
    echo "ERROR: no input arguments"
    exit
fi

# iterate over command arguments
for arg in "$@"; do
    # print help info
    if [ "$arg" = "-h" ]; then
        echo
        echo "pipeline.sh executable by Elia Covino & Arianna Rigamonti"
        echo
        echo "./pipeline.sh [-AR recessive disease case numbers] [-AD dominant disease case numbers] [-h help]"
        echo
        echo "example: ./pipeline.sh -AR 452 453 454 -AD 703 704 705"
        echo

        exit 
        
    # set recessive disease
    elif [ "$arg" = "-AR" ]; then
        recessive=true
    # set non-recessive disease (dominant)
    elif [ "$arg" = "-AD" ]; then
        recessive=false

    # check if the case number exists
    elif [ -f ${cases_path}"case"${arg}"_child.fq.gz" ]; then
        case_number=${arg}
        

        if [ ! -d "case"${case_number} ]; then
            mkdir "case"${case_number}
            echo "Running case $case_number..."
        else
            echo "Already present case $case_number."
            continue
        fi

        cd case${case_number}

        # ALIGNING
        echo "Aligning..."
        echo "Bootie2 - child..."
        bowtie2 -U ${cases_path}case${case_number}_child.fq.gz -p 8 -x ${cases_path}uni --rg-id 'SC' --rg "SM:child" | samtools view -Sb | samtools sort -o case${case_number}_child.bam 
        echo "Bootie2 - father..."
        bowtie2 -U ${cases_path}case${case_number}_father.fq.gz -p 8 -x ${cases_path}uni --rg-id 'SF' --rg "SM:father" | samtools view -Sb | samtools sort -o case${case_number}_father.bam
        echo "Bootie2 - mother..."
        bowtie2 -U ${cases_path}case${case_number}_mother.fq.gz -p 8 -x ${cases_path}uni --rg-id 'SM' --rg "SM:mother" | samtools view -Sb | samtools sort -o case${case_number}_mother.bam
        echo "Freebayes..."
        freebayes -f ${cases_path}universe.fasta -m 20 -C 5 -Q 10 --min-coverage 10 case${case_number}_mother.bam case${case_number}_child.bam case${case_number}_father.bam  > case${case_number}.vcf

        bcftools query -l case${case_number}.vcf | sort > vcf.sort.temp
        bcftools view -S vcf.sort.temp case${case_number}.vcf > case${case_number}.sorted.vcf
        grep "^#CHR" case${case_number}.sorted.vcf

        echo "grep # ..."
        grep "#" case${case_number}.sorted.vcf > candilist${case_number}.vcf

        diseaseFilter="1/1.*0/1.*0/1" # recessive
        if  [ $recessive != true ]; then
            diseaseFilter="0/1.*0/0.*0/0" # dominant
        fi

        grep ${diseaseFilter} case${case_number}.sorted.vcf  >> candilist${case_number}.vcf 
        
        grep "#" candilist${case_number}.vcf > ${case_number}candilistTG.vcf

        bedtools intersect -a candilist${case_number}.vcf -b /home/BCG2024_genomics_exam/exons16Padded_sorted.bed -u >> ${case_number}candilistTG.vcf

        # UCSC
        echo "bedtools for UCSC..."

        echo "bedtools -child"
        bedtools genomecov -ibam case${case_number}_child.bam -bg -trackline -trackopts 'name="child"' -max 100 > case${case_number}childCov.bg
        echo "bedtools -mother"
        bedtools genomecov -ibam case${case_number}_mother.bam -bg -trackline -trackopts 'name="mother"' -max 100 > case${case_number}motherCov.bg
        echo "bedtools -father"
        bedtools genomecov -ibam case${case_number}_father.bam -bg -trackline -trackopts 'name="father"' -max 100 > case${case_number}fatherCov.bg

        # FASTQC
        echo "fastqc..."

        echo "fastqc -child"
        fastqc ${cases_path}case${case_number}_child.fq.gz -o ./
        echo "fastqc -mother"
        fastqc ${cases_path}case${case_number}_mother.fq.gz -o ./
        echo "fastqc -father"
        fastqc ${cases_path}case${case_number}_father.fq.gz -o ./

        # QUALIMAP
        echo "qualimap..."

        qualimap bamqc -bam case${case_number}_child.bam -gff /home/BCG2024_genomics_exam/exons16Padded_sorted.bed -outdir case${case_number}_child
        qualimap bamqc -bam case${case_number}_mother.bam -gff /home/BCG2024_genomics_exam/exons16Padded_sorted.bed -outdir case${case_number}_mother
        qualimap bamqc -bam case${case_number}_father.bam -gff /home/BCG2024_genomics_exam/exons16Padded_sorted.bed -outdir case${case_number}_father

        # MULTIQC
        echo "multiqc..."

        multiqc -f /home/BCG2024_genomics_exam/case${case_number}* ./case${case_number}*

        echo "case $case_number DONE!"
        echo

        cd ../

    # error message and exit
    else
        echo
        echo "ERROR: wrong input value: $arg"
        echo "incorrect case number or unknown argument (only -r -d -h)"
        exit
    fi
done
