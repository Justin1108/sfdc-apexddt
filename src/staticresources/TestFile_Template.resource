{
    "DG-1" : {
        "contact1" : {
            "type" : "origin",
            "data" : {
                "firstname" : "Justin",
                "lastname" : "Yue",
                "account__r" : {
                	"name" : "5i5j",
                	"phone" : "6045448060",
                	"addr" : {
                		"Street" : "2110 9th Ave.",
                		"City" : "Vancouver",
                		"State" : "BC",
                		"Country" : "Canada"
                	}
                }
            },
            "action" : [{
                    "cmd" : "add",
                    "$.Birthdate" : "{!TODAY()}"
                }
            ]

        },
        "contact2" : {
            "type" : "duplicate",
            "path" : "/./DG1/contact1",
            "data" : {
            	"names" : [
            		"Justin",
            		"Lily",
            		"Mike",
            		"Michelle"
            	]
            },
            "action" : [{
                    "cmd" : "modify",
                    "$.Birthdate" : "{!Date(1968, 11, 8)}"
                }

            ]
        }
    },
    "DG-2" : {
        "contact3" : {
            "type" : "ref",
            "path" : "/./DG1/contact1",
            "action" : [{
                    "cmd" : "remove",
                    "$.Birthdate" : null
                }
            ]
        }
    }
}
