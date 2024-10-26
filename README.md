# African Pangenome BYOD Workshop, Cape Town 21st-25th Oct,2024.

# Background:

We have built our pangenome beforehand from 27 samples `HiFi Long reads with 30x coverage`, using a the workflow that we developed in [WDL](https://github.com/openwdl/wdl/blob/wdl-1.2/SPEC.md). 

<p align="center">
  <img src="https://github.com/Mo7ammedFarahat/LinearVSGraph/blob/main/images/General_Workflow.png" alt="Diagram" width="500">
</p>

As you see, the workflow designed to do raw reads QC, assemblies and assemblies QC. It also recording tools' versions since it pulls `docker images` with latest versions in every run.

After assemblies, we built the pangenome graph using `Mini-graph Cactus`.
---

# LinearVSGraph


It's prefered to open a tmux session before submit the job, like
```
tmux new-session -t compare
```
To deattach the session, do:
```
ctrl+b then press d
```
To reattach that session again using:
```
tmux attach-session -t compare
```


<p align="center">
  <img src="https://github.com/Mo7ammedFarahat/LinearVSGraph/blob/main/images/Compare.png" alt="Diagram" width="500">
</p>

**Scripts Dir**
```
/cbio/projects/037/workshop_scripts
```

## Step1: Calling variants from chm13 graph then surject to hg38:
### A) Align our samples against the African Pangenome (27 30x):

Create a dir named `align_graph` then a subdir called `african27`, like:
```
cd /cbio/projects/037/your_personal_dir
mkdir align_graph/african27/
cd align_graph/african27
```
Let's create 5 empty dirs and naming them with the samples names
```
mkdir sample1 sample2 sample3 sample4 sample5
```

Now, let's soft link your samples inside that dir (each sample has a separated dir), like
```
ln -s /path/to/your/sample/read1.fastq.gz /cbio/projects/037/your_personal_dir/align_graph/african27/sample1/sample_name_r1.fastq.gz


ln -s /path/to/your/sample/read2.fastq.gz /cbio/projects/037/your_personal_dir/align_graph/african27/sample1/sample_name_r2.fastq.gz
```
Copy the script from here to **each** sample directory
```
cd align_graph/african27/sample1
cp /cbio/projects/037/workshop_scripts/wgs_align_baylor30x27_graph_call_DeepVariant.sbatch .
```
**Now Let's modify the script**  
Open the script in your prefered text editor, like:
```
nano wgs_align_baylor30x27_graph_call_DeepVariant.sbatch
```
As you see now you have a section for the samples' paths here:
```
# replace with paths to your own directories and sample data

TMPDIR=/cbio/projects/037/melissa/align_graph_deepvariant/SAMN01090776/
OUTDIR=/cbio/projects/037/melissa/align_graph_deepvariant/SAMN01090776/
FASTQ1=/cbio/projects/037/gerrit/1kg/fastq/SAMN01090776/SAMN01090776_R1.fastq.gz
FASTQ2=/cbio/projects/037/gerrit/1kg/fastq/SAMN01090776/SAMN01090776_R2.fastq.gz
SAMPLE_ID=SAMN01090776
```
Modify that section with the your sample paths. 
You need also to modify the first line in the script `-D` here
```
#!/bin/bash
#SBATCH -D /path/to/your/working/directory
```
Now, submit it like that:

```
sbatch wgs_align_baylor30x27_graph_call_DeepVariant.sbatch
```
Do the same for the other samples (soft link the samples, copy the script, modify it and submit)


### B) Align our samples against the HPRC Graph:

Again, inside the `align_graph` dir that we created above, create a subdir called `HPRC`, like:
```
cd /cbio/projects/037/your_personal_dir/align_graph
mkdir HPRC
cd HPRC
```
Then create 5 empty dirs and naming them with the samples names
```
mkdir sample1 sample2 sample3 sample4 sample5
```
Soft link the samples to those dirs as we did ealier, then copy the script in **each** dir from here:
```
/cbio/projects/037/workshop_scripts/wgs_align_hprc_graph_call_DeepVariant.sbatch
```
Open the script in your text editor and modify the paths, then submit it.

Note: It will take from 8-20 hours depending on your samples coverages.

## Step2: Comparing VCFs from linear alignment vs graph:

Once Step1 is done, you will got vcf for each sample from both our African Pangenome and the HPRC. Now lets compare them to the VCF from the linear reference.

### A) Compare VCFs generated from linear alignment VS African27 VCFs
Go to your your_personal_dir and create a new dir called `compare_linear_graph_vcf`, inside that dir create a subdir called 'african27`.

Change the wd to `/compare_linear_graph_vcf/african27`

Create 5 subdir for your 5 samples, then copy the comparing script to each dir from here:

```
cp /cbio/projects/037/workshop_scripts/vcf_compare_linear_vs_graph_fix_chr_names.sbatch /path/to/compare_linear_graph_vcf/african27/sample1/
```
Open the script in an text editor and update the following paths to be your VCFs paths:

```
# provide paths for the two VCF files to compare (associated indices should be present):

VCF_LINEAR=/cbio/projects/037/gerrit/examples/SAMN00000499.pass.vcf.gz
VCF_GRAPH=/cbio/projects/037/melissa/align_graph_deepvariant/SAMN00000499/SAMN00000499.Baylor30x27_surject_hg38_PASS.dv.vcf.gz
```
Now, sumbit the script.
Remember, you will do the same for all the other samples.


### B) Compare VCFs generated from linear alignment VS HPRC VCFs

Go back again to `/compare_linear_graph_vcf` dir and create a subdir named `HPRC`, then create 5 subdir inside it for your 5 samples.

Copy the comparing script to each dir from here:
```
/cbio/projects/037/workshop_scripts/vcf_compare_linear_vs_graph.sbatch
```

Open the script with your text editor and update those lines with your VCFs paths.
```
# provide paths for the two VCF files to compare (associated indices should be present):

VCF_LINEAR=/cbio/projects/037/gerrit/examples/SAMN00000499.pass.vcf.gz
VCF_GRAPH=SAMN00000499_Baylor30x27_surject_hg38_PASS_rename_chrs.dv.vcf.gz
```
Submit the script.


<details>
<summary>The output files:</summary>  
  
- Unique high quality variants?
- Annotated variants?
- Number of variants per gene?
- High and moderate impact variants.

</details>


What are the results you got? did you get some statistics and differences? Interesting?!  
The following Venn diagram shows the number of variants in both approaches for one of our samples 'MND_G161.1ABD` *Neurogenomics Lab. UCT*, There is a big overlap between 'hg38 linear' alignment vs 'CHM13 13 graph' surjected to hg30.bam *(to be comparable)*. There is a number of unique variants in the graph that are not represented in the linear reference, and some variants in linear are not in the graph.
 

<p align="center">
  <img src="https://github.com/Mo7ammedFarahat/LinearVSGraph/blob/main/images/Venn.png" alt="Venn" width="500">
</p>


<details>
<summary>Can you visualize genes of interest?:</summary>  
  
- You can use this [script](https://github.com/Mo7ammedFarahat/LinearVSGraph/blob/main/gene-cord.sh) to get the coordinates of your gene.
- Open IGV and compare the results in both approaches.

Here is an example of the results of the same sample for 'CBS` and `HLA-DRB5` genes in both approaches.

Info: As you know there are genes that are falsly duplicated/collapsed in `hg38` which are resolved in `CHM13`, one of these genes is `CBS` which is falsly duplicated in `hg38`, as you see in the following figure the mapping quality difference between the linear and the graph. Since falsly duplicated regions leads to multi-mapping problems. 

<p align="center">
  <img src="https://github.com/Mo7ammedFarahat/LinearVSGraph/blob/main/images/CBS.png" alt="CBS" width="500">
</p>

---

For 'HLA-DRB5` gene which known as highly polymorphic, the mapping quality are equal in both approaches, however there is a difference between the coverage in both approaches.

<p align="center">
  <img src="https://github.com/Mo7ammedFarahat/LinearVSGraph/blob/main/images/HLA.png" alt="HLA" width="500">
</p

</details>

Now, it's the time to play around your data and discover more interesting findings.

