"X didnt run"
Is your path to the database correct?

OUT of memory
Make sure you edit the base.config and sneure you limit to your available resources

"How long will my analysis take?"
depends

"What does the PLATO profile include?"
Binds to the temp directory or else it has to access

"cant run the custom vis"
ensure the permissions are correct for the files chmod +x bin/*

How many CPUs should I request?
Most tools scale to 8-16 CPUs. Check tool documentation.

"where are my output files?"
Check the directory where you submitted the job, or location specified in your script.

Pipeline crashes at step x
check the .nextflow.log file. Often it is low memory

Should I trim adapters before running?
 The pipeline includes trimming. Provide raw reads. When considering polishing though, the trimming or quality control step is not included unless a part of the assembly, i.e if polishing a short read illumina assembly with nanopore reads. you may want to trim or qualtiy control before polishing.
