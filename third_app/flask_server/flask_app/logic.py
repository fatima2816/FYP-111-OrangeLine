

from rdflib import Graph, URIRef, Namespace
from rdflib.plugins.sparql import prepareQuery
from rdflib import Graph


# Load the OWL file
g = Graph()
g.parse("orange.owl", format="xml")  

def extractFaultSolution(user_entry_text):
    query = """
        PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    PREFIX ontology: <http://www.semanticweb.org/zuhaumar/ontologies/2023/10/untitled-ontology-12#>

    SELECT ?system
    WHERE {
    ?system rdf:type ontology:System.
    }
    """    
    # Execute the query
    results = g.query(query)

    # # Print the results
    # for row in results:
    #     print(row)

    # Extract the values after the '#' symbol for all rows
    System_from_graph= [uri_ref.split('#')[-1] for row in results for uri_ref in row]
    print("\n System graph list: ")
    print(System_from_graph)
    # Replace underscores with spaces in the list
    user_System_list = [word.replace('_', ' ') for word in System_from_graph]
    print("\n user list: ")
    print(user_System_list)

 

    # Convert modified_list to a set for efficient lookup
    mentioned_systems = [system for system in user_System_list if system.lower() in user_entry_text.lower()]
    print("\nThe extracted system list:")
    print(mentioned_systems)

    # Get the indices of mentioned systems in user_System_list
    system_indices = [index for index, system in enumerate(user_System_list) if system in mentioned_systems]
    print("\nThe extracted system indices:")
    print(system_indices)



    # Extract systems from user_System_list using the obtained indices
    selected_systems = [System_from_graph[index] for index in system_indices]

    # Generate the VALUES clause for the systems
    values_clause = " ".join([f"ontology:{system}" for system in selected_systems])

    print(values_clause)

    # SPARQL query template
    sparql_query_template = """
        PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
        PREFIX ontology: <http://www.semanticweb.org/zuhaumar/ontologies/2023/10/untitled-ontology-12#>

        SELECT ?system ?equipment
        WHERE {{
        VALUES ?system {{ {values_clause} }}
        ?system rdf:type ontology:System;
                ontology:hasEquipment ?equipment.
        }}
    """

    # Replace placeholders in the SPARQL query template
    sparql_query = sparql_query_template.format(values_clause=values_clause)

    #Execute the SPARQL query
    results2 = g.query(sparql_query)

    # List to store equipment lists for each system
    system_equipment_lists = []

    # Counter for naming equipment lists
    eqp_list_counter = 1

    # Iterate through the results and save each equipment list separately
    for row in results2:
        system_uri = row[0]
        system = system_uri.split('#')[-1]
        equipment = row[1].split('#')[-1]

        # Check if the system is already in the list
        system_found = False
        for system_equipment_list in system_equipment_lists:
            if system_equipment_list[0] == system:
                system_equipment_list.append(equipment)
                system_found = True
                break

        # If the system is not found, create a new list for it
        if not system_found:
            new_equipment_list_name = f"eqp{eqp_list_counter}"
            new_equipment_list = [system, equipment]
            system_equipment_lists.append(new_equipment_list)
            eqp_list_counter += 1

    # Print or use the equipment lists as needed
    for system_equipment_list in system_equipment_lists:
        system = system_equipment_list[0]
        equipment_list_graph = system_equipment_list[1:]
        equipment_list_name = f"eqp{eqp_list_counter}"
        print(f"Equipment: {equipment_list_graph}")
        # Replace underscores with spaces in the list
        user_equipment_list = [word.replace('_', ' ') for word in equipment_list_graph]
        print("\n user list: ")
        print( user_equipment_list)

        
        # Convert modified_list to a set for efficient lookup
        mentioned_equipments = [equipment for equipment in user_equipment_list if equipment.lower() in user_entry_text.lower()]
        print("\nThe extracted equipments list:")
        print(mentioned_equipments)
    
        first_equipment = mentioned_equipments[0]
        
      # Get the indices of mentioned systems in user_System_list
    equipment_indices = [index for index, equipment in enumerate(user_equipment_list ) if equipment in mentioned_equipments]
    print("\nThe extracted equipmentindices:")
    print(equipment_indices)

    # Extract systems from user_System_list using the obtained indices
    selected_equipment = [equipment_list_graph[index] for index in equipment_indices]
    print(selected_equipment)
    final_equipment=selected_equipment[0]

    
    
    sparql_query_template2 = """
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    PREFIX ontology: <http://www.semanticweb.org/zuhaumar/ontologies/2023/10/untitled-ontology-12#>

    SELECT ?fault
    WHERE {{
        ontology:{} rdf:type ontology:Equipment;
                   ontology:hasFault ?fault.
    }}
""".format(final_equipment)


    # Execute the query
    results3 = g.query(sparql_query_template2)
    
    fault_list=[]
    # Print the results
    for row in results3:
        fault_type_uri = row[0]  
        fault_type = fault_type_uri.split('#')[-1]
        print(fault_type)
        fault_list.append(fault_type)

    print(fault_list)
    
    mentioned_faults = [fault for fault in fault_list if fault.lower().replace(" ", "") in user_entry_text.lower().replace(" ", "")]

    print("\nThe extracted faults list:")
    print(mentioned_faults)

    fault_string=mentioned_faults[0]
    mentioned_fault= ''.join(fault_string.split())
    
    print(mentioned_fault)
     # SPARQL query template
    sparql_query_template3 = """
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

    SELECT ?comment
    WHERE {{
    <http://www.semanticweb.org/zuhaumar/ontologies/2023/10/untitled-ontology-12#{mentioned_fault}> rdf:type <http://www.semanticweb.org/zuhaumar/ontologies/2023/10/untitled-ontology-12#Fault> .
    <http://www.semanticweb.org/zuhaumar/ontologies/2023/10/untitled-ontology-12#{mentioned_fault}> rdfs:comment ?comment .
    }}
    """


    # Execute the SPARQL query
    results4 = g.query(sparql_query_template3.format(mentioned_fault=mentioned_fault))
    print("results:",results4)
    # Print the results
    for result in results4:
        
        print("the result is ",result)
      
        return result

 

