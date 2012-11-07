Reconstructing-Books-from-Google-Ngrams
===================================

- Google has collection of consecutive words from scanned books. Question is to what extent large chunks of the book text can be reconstructed from this. It is a sequence assembly problem, but on a big alphabet (words)

- Our system downloads books from Project Gutenberg, splits these books into NGrams (N=2 to 10) and then runs a sequence assembly program to reconstruct the books

- Our system achieved a peak performance by assembling 22 million 10Grams in 2 min with 100% accuracy on a machine with 2.1 Ghz CPU and 4 GB of memory

- Used C, C++ STLs, FNV Hash, Trie, STL hacks, Linux