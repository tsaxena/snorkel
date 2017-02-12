# We will do the following terribly hackey / roundabout procedure...
# 
# Assume that the CDR corpus has been run through the CorpusParser and is in the cdr-structure-learning DB
# This script will:
# 1. Transfer data from snorkel-biocorpus-new;
# 2. Delete the overlapping data with the CDR corpus;
# 3. Drop the CDR corpus and insert the biocorpus data.
#
# Then, you can re-run the CDR CorpusParser to add back in the CDR corpus properly.

# Transfer tables from snorkel-biocorpus-new DB
pg_dump -t context_filtered_kw snorkel-biocorpus-new | psql cdr-structure-learning
pg_dump -t document_filtered_kw snorkel-biocorpus-new | psql cdr-structure-learning
pg_dump -t sentence_filtered_kw snorkel-biocorpus-new | psql cdr-structure-learning

# Delete overlap with tables
psql -d cdr-structure-learning -c "DELETE FROM context_filtered_kw cf WHERE cf.stable_id IN (SELECT stable_id FROM context);"
psql -d cdr-structure-learning -c "DELETE FROM sentence_filtered_kw sf USING document_filtered_kw df WHERE sf.document_id = df.id AND df.name IN (SELECT name FROM document);"
psql -d cdr-structure-learning -c "DELETE FROM document_filtered_kw df WHERE df.name IN (SELECT name FROM document);"
