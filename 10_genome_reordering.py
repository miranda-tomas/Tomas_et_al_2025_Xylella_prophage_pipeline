#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# *****************************************************************************
# 10_genome_reordering.py
#
# This script reorders a set of FASTA genome files using a reference sequence 
# as the starting point. Coordinates are obtained through a BLASTn alignment 
# between the reference and each genome.
#
# It requires as input:
#   (1) a list of input FASTA files,
#   (2) a reference FASTA file, and
#   (3) the output file name for the BLAST alignment results.
#
# Author: Miranda Tomas
# *****************************************************************************

from Bio import SeqIO
import sys, os, subprocess

def run_blast(query_file: str, subject_file: str, blast_file: str):
    """
    Runs a BLASTn alignment between two FASTA files and appends results to an output file.

    Parameters
    ----------
    query_file : str
        Query FASTA file.
    subject_file : str
        Subject FASTA file.
    blast_file : str
        Output file where BLAST results will be appended.
    """
    cmd = f"blastn -query {query_file} -subject {subject_file} -max_target_seqs 1 -max_hsps 1 -outfmt 6 >> {blast_file}"
    subprocess.run(cmd, shell=True, check=True)


def reverse_fasta(in_file: str, out_file: str):
    """
    Generates the reverse complement of a FASTA sequence and writes it to a new file.

    Parameters
    ----------
    in_file : str
        Input FASTA file.
    out_file : str
        Output FASTA file for the reversed sequence.
    """
    for record in SeqIO.parse(open(in_file), "fasta"):
        reverse_seq = record.seq.reverse_complement()
        with open(out_file, "w") as out:
            out.write(f">{record.id}_reversed\n{reverse_seq}\n")


def reorder_fasta(in_file: str, out_file: str, pos: int):
    """
    Reorders a FASTA genome starting at a given coordinate.

    Parameters
    ----------
    in_file : str
        Input FASTA file.
    out_file : str
        Output FASTA file for the reordered sequence.
    pos : int
        Coordinate where the sequence will start.
    """
    for record in SeqIO.parse(open(in_file), "fasta"):
        seq = str(record.seq)
        reordered = seq[pos - 1:] + seq[:pos - 1]
        with open(out_file, "w") as out:
            out.write(f">{record.id}\n{reordered}\n")


def main():
    if len(sys.argv) != 4:
        print("Usage: python3 10_genome_reordering.py <input_files> <reference.fasta> <blast_output.txt>")
        sys.exit(1)

    input_files = sys.argv[1]
    reference = sys.argv[2]
    blast_output = sys.argv[3]

    # Run BLAST for each input file
    for in_file in input_files.split():
        run_blast(reference, in_file, blast_output)

    # Read BLAST results and reorder or reverse genomes accordingly
    with open(blast_output, "r") as blast_results:
        for line in blast_results:
            fields = line.split()
            subject = fields[1]
            start, end = int(fields[8]), int(fields[9])

            if start > end:
                reversed_file = f"{subject}_reversed.fasta"
                reverse_fasta(subject, reversed_file)
                run_blast(reference, reversed_file, blast_output)
            elif start < end:
                reordered_file = f"{subject}_reordered.fasta"
                reorder_fasta(subject, reordered_file, start)


if __name__ == "__main__":
    main()
