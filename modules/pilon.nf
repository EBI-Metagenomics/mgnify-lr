process pilon {
  label 'pilon'
        publishDir "${params.output}/${name}/assembly", mode: 'copy', pattern: "${name}_pilon_polished.fasta"
      input:
        tuple val(name), file(assembly)
        tuple val(read_name), file(read) 
      output:
  	    tuple val(name), file("${name}_pilon_polished.fasta") 
      script:
        """
        bwa index ${assembly}
        bwa mem ${assembly} ${read[0]} ${read[1]} | samtools view -bS - | samtools sort -@ ${task.cpus} - > ${name}.1.bam
        samtools index -@ ${task.cpus} ${name}.1.bam
        pilon -Xmx${params.memory}g --threads ${task.cpus} --genome ${assembly} --frags ${name}.1.bam --output round2
        bwa index round2.fasta
        bwa mem round2.fasta ${read[0]} ${read[1]} | samtools view -bS - | samtools sort -@ ${task.cpus} - > ${name}.2.bam
        samtools index -@ ${task.cpus} ${name}.2.bam
        pilon -Xmx${params.memory}g --threads ${task.cpus} --genome round2.fasta --frags ${name}.2.bam --output ${name}_pilon_polished
      	"""
}