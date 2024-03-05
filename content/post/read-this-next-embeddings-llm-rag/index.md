---
title: "Read This Next: Using AI For Recommending Posts On My Blog"
date: 2024-03-03
slug: read-this-next-embeddings-llm-rag
tags: ["programming", "llm", "embeddings", "meta"]
description: How I built a post recommendation feature for my blog using text embeddings, GPT-4 and ChromaDB with LangChain
---

Imagine landing on a blog where every "Read This Next" suggestion feels like it was handpicked just for you. 

That's the kind of reading journey I want for you on my blog.

I've been experimenting, trying to develop a system that not only understands the content of my posts but also why they might resonate with you, the reader. This feature is **now live**, and I'm going to explore the process.

## Why Move Beyond Traditional Recommendation Systems?
Hugo has a pretty good, very configurable keyword and category based recommendation system. With careful selection and tweaking of weights, I've been able to have it recommend stuff to my liking so far.

But that's not what I wanted.

Have you ever finished an article on AI ethics only to be recommended a generic post on "Top 10 AI Innovations"? It's informative, sure, but it misses the mark on continuing the nuanced conversation you were engaged in.

I wanted to dig deeper. I wanted to create a recommendation that felt almost like a friend was suggesting what you should read next- Related, but also having a wide range of topics. 

This required a system capable of understanding content at a near-human level and making connections between seemingly disparate topics based on underlying themes and ideas.

## RAG, Text Embeddings and GPT-4

To bridge this gap, I turned to AI, specifically text embeddings and GPT-4. I used LangChain to make interacting with the tools easier, though in future posts I will explore further on using the core modules directly.

Text embeddings allow us to transform written content into numerical vectors, representing the essence of a post in a form that computers can understand and compare. It's like capturing the soul of an article in numbers. GPT-4, on the other hand, offers an advanced understanding of language, capable of generating summaries, and even explaining why one article relates to another in a human-like manner.

For instance, an article on the ethical considerations of AI could lead you to a seemingly unrelated post on philosophy, connected by the underlying theme of ethics and technology.

This is an application of the well known RAG (Retrieval Augmented Generation) pattern.

## Summarizing Posts
The process starts off when a summary is generated for each blog post using LangChain and OpenAI's GPT-4 model. 

The script employs a [map-reduce approach](https://harikirankante.hashnode.dev/how-to-summarize-large-documents-using-langchain-and-openai-in-python) where each document (part of a blog post) is first summarized individually (map step), and then these section wise summaries are further condensed (reduce step).

```python
from langchain.chains import (LLMChain, MapReduceDocumentsChain,
                              ReduceDocumentsChain)
from langchain.chains.combine_documents.stuff import StuffDocumentsChain
from langchain.prompts import PromptTemplate
from langchain.text_splitter import TokenTextSplitter
from langchain_community.document_loaders import UnstructuredMarkdownLoader
from langchain_openai.chat_models import ChatOpenAI

map_template = """Write a concise summary of the following content:

{content}

Summary:
"""
map_prompt = PromptTemplate.from_template(map_template)
llm = ChatOpenAI(model="gpt-4-turbo-preview")
map_chain = LLMChain(prompt=map_prompt, llm=llm)

reduce_template = """The following is set of summaries:

{doc_summaries}

Summarize the above summaries with all the key details
Summary:"""
reduce_prompt = PromptTemplate.from_template(reduce_template)
reduce_chain = LLMChain(prompt=reduce_prompt, llm=llm)
stuff_chain = StuffDocumentsChain(
    llm_chain=reduce_chain, document_variable_name="doc_summaries")

reduce_chain = ReduceDocumentsChain(
    combine_documents_chain=stuff_chain,
)

map_reduce_chain = MapReduceDocumentsChain(
    llm_chain=map_chain,
    document_variable_name="content",
    reduce_documents_chain=reduce_chain
)

post = "./post/name-of-post/index.md"
loader = UnstructuredMarkdownLoader(post)
docs = loader.load()

splitter = TokenTextSplitter(chunk_size=2000)
split_docs = splitter.split_documents(docs)

summary = map_reduce_chain.invoke(split_docs)
print(summary["output_text"])
```

## Embedding and Storing

The generated summaries are then processed through a text embedding model. This converts the summaries into a high-dimensional space where similar contents are positioned closer together, facilitating the comparison of thematic and semantic similarities between posts.

These embeddings are stored in ChromaDB, a vector database optimized for fast similarity searches.

```python
import json

from langchain.embeddings import CacheBackedEmbeddings
from langchain.storage import LocalFileStore
from langchain_community.vectorstores import Chroma
from langchain_core.documents import Document
from langchain_openai import OpenAIEmbeddings

summaries = json.loads(open("sum.json", "r").read())

underlying_embeddings = OpenAIEmbeddings(model="text-embedding-3-large")

store = LocalFileStore("./cache/")

cached_embedder = CacheBackedEmbeddings.from_bytes_store(
    underlying_embeddings, store, namespace=underlying_embeddings.model
)

docs = []
for k in summaries.keys():
    sum_source = k.split("/")[2]
    sum_page = summaries[k]
    doc = Document(page_content=sum_page, metadata={'source': sum_source})
    docs.append(doc)

db = Chroma.from_documents(docs, cached_embedder)
```

## Finding Related Posts

To find similar posts, we query ChromaDB with the embedding of the current post, retrieving other posts with the closest embeddings. This step uses Maximal Marginal Relevance, an algorithm that considers both similarity and diversity, making sure that recommendations are both relevant and varied.

For each recommended post, GPT-4 is used to generate an engaging, brief explanation of why it might be of interest, based on the thematic connections identified through the embeddings. 

This step adds a personal touch to the recommendations, making them feel more curated and thoughtful.

```python
from collections import defaultdict

from langchain.chains import LLMChain
from langchain.prompts import PromptTemplate
from langchain_openai import ChatOpenAI

relateds = defaultdict(list)
rec_template = """You are an intelligent AI-powered content recommendation assistant. 

Here's a summary of the article that the reader has just read:
{summary_a}

Here's a summary of the next article recommended for the reader:
{summary_b}

Now, write why the reader might find it interesting based on the contents of both the articles. 
Don't say things like "Given", "Dive in", "Elevate" etc.
Always start with a attention grabbing, relevant and catchy hook.
Your answer should explain in no more than one sentence using clear, concise, conversational language.
Don't be superfluous, use superlatives or exaggerate. Always be practical. 
Always refer to the reader as "you" and the author in the first person.
"""

llm = ChatOpenAI(model="gpt-4-turbo-preview", temperature=0.2)
rec_prompt = PromptTemplate.from_template(rec_template)
rec_chain = LLMChain(prompt=rec_prompt, llm=llm)
for k in summaries.keys():
    print("For: ", k)
    sum_source = k.split("/")[2]
    sum_page = summaries[k]
    found_docs = db.max_marginal_relevance_search(
        sum_page, k=3, fetch_k=len(summaries.keys()) - 1,
        filter={"source": {"$ne": sum_source}}
    )
    for i, doc in enumerate(found_docs):
        result = rec_chain.invoke({"summary_a": sum_page, "summary_b": doc.page_content})
        relateds[k].append({"slug": f'post/{doc.metadata["source"]}', "why": result["text"]})

print(relateds)
```

## Putting It All Together
Finally, now that I have the list of related posts, I'm going to put them in a `next.json` content file next to each post's `index.md`.

```json
{
    "read_next": [
        {
            "slug": "post/2023-07-09-programming-with-the-grain",
            "why": "You might dig the next article because it switches gears from the nifty math trick you just explored to the practical world of programming, showing you how to ride the wave of a language's inherent features for smoother coding. It's like applying a smart formula but in the realm of coding, making your work not just correct but elegantly efficient."
        },
        {
            "slug": "post/2023-06-20-facebook-graph-leads-between",
            "why": "The reader, having just explored a mathematical trick for estimating digits in powers of 2, might find the next article intriguing as it shifts focus from theoretical math to practical application, demonstrating how to leverage Python and the Facebook Graph API for data retrieval tasks. This presents an opportunity to see Python's versatility in action, from performing mathematical computations to interacting with web APIs."
        },
        {
            "slug": "post/2021-09-18-pem-linux",
            "why": "If you enjoyed learning a neat mathematical trick for estimating digits in powers of two, you might find diving into the practical world of cryptography with RSA key generation equally fascinating. It's a cool way to see how mathematical concepts can be applied to enhance security in computing tasks like setting up secure, passwordless connections."
        }
    ]
}
```

Finally, I create a shortcode to display the recommendations inside the post in `layouts/shortcodes/read-next.html`:

```
{{ $dataFile := "next.json" }}
{{ range .Page.Resources.Match $dataFile }}
{{ $data := .Content | transform.Unmarshal }}
# Read Next
I'm running [an experiment](/blog/read-this-next-embeddings-llm-rag/) for better content recommendations. These are the 3 posts that are most likely to be interesting for you:

{{ range $data.read_next }}
{{ $page := site.GetPage .slug }}
{{ if $page }}
- [{{ $page.Title }}]({{ $page.RelPermalink }})  
    {{ .why | markdownify }}
{{ else }}
{{/* Handle the case where the page is not found */}}
{{ printf "Recommended reading not found for slug or filename: '%s'" .slug }}
{{ end }}
{{ end }}
{{ end }}
```

And here's the result:

{{% read-next %}}
