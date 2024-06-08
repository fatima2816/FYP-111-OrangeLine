from rdflib import Graph
from rdflib.plugins.sparql import prepareQuery

# `get_system` is a function that queries the ontology
def get_system(class_instance):
    # Create an RDF graph
    g = Graph()

    # Load the RDF file
    rdf_file = "orange.owl"  # Replace this with the path to your RDF file
    g.parse(rdf_file, format='xml')  # Use the appropriate format if not RDF/XML

    # Define the SPARQL query template
    sparql_query_template = """
        PREFIX first: <http://www.semanticweb.org/zuhaumar/ontologies/2023/10/untitled-ontology-12#>
        SELECT ?instance
        WHERE {{
            ?instance rdf:type first:{}
        }}
    """

    sparql_query = sparql_query_template.format(class_instance)

    # Prepare and execute the SPARQL query
    #query = prepareQuery(sparql_query)
    results = g.query(sparql_query)

    fragment = ['Select system']

    # Process query results
    for row in results:
        fragment.append(row[0].split('#')[-1] if '#' in row[0] else row[0].split('/')[-1])

    return fragment

def get_equipment(system_instance):
    # Create an RDF graph
    g = Graph()

    # Load the RDF file
    rdf_file = "orange.owl"  # Replace this with the path to your RDF file
    g.parse(rdf_file, format='xml')  # Use the appropriate format if not RDF/XML

    # Define the SPARQL query template
    sparql_query_template = """
            PREFIX first: <http://www.semanticweb.org/zuhaumar/ontologies/2023/10/untitled-ontology-12#>
            SELECT ?equipment
            WHERE {{
                ?selectedSystem rdf:type first:System ;
                                first:hasEquipment ?equipment .
                FILTER (?selectedSystem = first:{})
            }}
        """

    sparql_query = sparql_query_template.format(system_instance)

    # Prepare and execute the SPARQL query
    #query = prepareQuery(sparql_query)
    results = g.query(sparql_query)

    fragment = ['Select equipment']

    # Process query results
    for row in results:
        fragment.append(row[0].split('#')[-1] if '#' in row[0] else row[0].split('/')[-1])

    return fragment

def get_location(equipment_instance):
    # Create an RDF graph
    g = Graph()

    # Load the RDF file
    rdf_file = "orange.owl"  # Replace this with the path to your RDF file
    g.parse(rdf_file, format='xml')  # Use the appropriate format if not RDF/XML

    # Define the SPARQL query template
    sparql_query_template = """
            PREFIX first: <http://www.semanticweb.org/zuhaumar/ontologies/2023/10/untitled-ontology-12#>
            SELECT ?location
            WHERE {{
                ?selectedEquipment rdf:type first:Equipment ;
                                first:isLocated ?location .
                FILTER (?selectedEquipment = first:{})
            }}
        """

    sparql_query = sparql_query_template.format(equipment_instance)

    # Prepare and execute the SPARQL query
    #query = prepareQuery(sparql_query)
    results = g.query(sparql_query)

    fragment = ['Select location']

    # Process query results
    for row in results:
        fragment.append(row[0].split('#')[-1] if '#' in row[0] else row[0].split('/')[-1])

    return fragment