
{
    "DG-1" : {
        "contact1" : {
            "type" : "origin",
            "data" : {
                "firstname" : "Justin",
                "lastname" : "Yue"
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
