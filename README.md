# cgisfbot
This is a Tumblr bot that produces random sentences. The goal is to be grammatically correct but meaningless, like the famous "colorless green ideas sleep furiously." The original cgisfbot generates sentences recursively, by breaking them down into clauses which can contain any number of subjects and predicates; I have also added a second version, impulsivebot, that generates sentences word-by-word, with minimal "awareness" of the larger structure of the sentence.

Currently, the bots only produce present-tense sentences, because I didn't want to try to code conjugation.
Potential future todos include:

Syntactic todos:
  - interjections
  - past and future tenses (and participles?!)
  - plural nouns and the verbs that conjugate for them
  - more advanced punctuation
  - verbs that are phrases ("puts out", "eats up", "doubles down", "gets nerfed")
  - helping verbs
  - the passive voice?
  - handling irregular verbs ("buy" is still "buys," but "try" should become "tries" instead of "trys")
  
Non-syntactic todos:
  - running from a remote server all the time, instead of from my computer when I remember to start the bots up
  - answering asks
    - when answering asks, looking up new words in a dictionary (dictionary.com, maybe?) and adding them to the word lists
    - when answering asks, using words from the ask in the response



The bots share a vocabulary, which comes mostly from EnchantedLearning.com. Word lists are as follows:
- adjectives: http://www.enchantedlearning.com/wordlist/adjectives.shtml
- verbs: http://www.enchantedlearning.com/wordlist/verbs.shtml
- adverbs: http://www.enchantedlearning.com/wordlist/adverbs.shtml
- conjunctions: http://www.enchantedlearning.com/wordlist/conjunctions.shtml
- prepositions: http://www.enchantedlearning.com/wordlist/prepositions.shtml

However, Enchanted Learning doesn't have a nouns sheet, so I took the noun list from Talk English at https://www.talkenglish.com/vocabulary/top-1500-nouns.aspx. (Unfortunately, some of the "nouns" on this list are not, in fact, nouns, and I haven't removed all of those.) I also modified the lists a little to include words like "scalie," "lawyer," "bisexual," and "glomp," and to remove words I thought were boring, unpleasant, or miscategorized.

I would love contributions to this repo! Like I said above, there's a lot I haven't done with this, and realistically, I'm not going to any time soon; it's a fun project I'm doing on a whim, and it's at the mercy of my work schedule and my level of interest. But it'd be sweet if it became collaborative!
