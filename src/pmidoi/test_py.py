import requests
import re

def doi_to_citation(doi):
    # Define the DOI resolver URL
    resolver_url = f"https://doi.org/{doi}"

    try:
        # Send an HTTP GET request to the resolver URL
        response = requests.get(resolver_url)

        # Check if the request was successful
        if response.status_code == 200:
            # Extract citation information from the response text
            citation_info = re.search('<meta name="citation_title" content="(.*?)">', response.text)
            if citation_info:
                title = citation_info.group(1)
                author_info = re.search('<meta name="citation_author" content="(.*?)">', response.text)
                if author_info:
                    author = author_info.group(1)
                else:
                    author = "Unknown Author"

                year_info = re.search('<meta name="citation_year" content="(.*?)">', response.text)
                if year_info:
                    year = year_info.group(1)
                else:
                    year = "Unknown Year"

                # Create the citation in APA format
                citation = f"{author} ({year}). {title}. DOI: {doi}"
                return citation
            else:
                return "Citation information not found."
        else:
            return "Failed to fetch DOI information."
    except requests.exceptions.RequestException as e:
        return f"Error: {e}"


# Example usage:
doi = "10.1002/0471142301"
doi="10.1093/bib/bbad342"
doi="10.1038/s41534-023-00740-6"

citation = doi_to_citation(doi)
print("APA Citation:", citation)
