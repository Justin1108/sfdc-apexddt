
/*
 * @description 
 */
public with sharing class TestDataFile {
    /*
     * @description type of the data unit, data, reference or duplicate
     */
    public enum DataUnitType { Data, Ref, Dup }

    /* 
     * @description field action on the data unit
     */
    public with sharing class DataUnitAction {
        public String cmd;
        public String jPath;
        public String value;
    }

    /*
     * @description data unit
     */
    public with sharing class DataUnit {
        public String unitType;
        public Object data;
        public String path;
        public DataUnitAction[] actions;

        public void parse(JSONParser parser) {
            if (parser.nextToken() == System.JSONToken.START_OBJECT) {
                while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                    if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                        String fName = parser.getCurrentName();
                        if (fName == 'type') {
                            //
                            parser.nextValue();
                            unitType = parser.getText();
                        } else if (fName == 'data') {
                            //
                            parser.nextToken();
                            parser.skipChildren();
                        } else if (fName == 'path') {
                            //
                            parser.nextValue();
                            path = parser.getText();
                        } else if (fName == 'action') {
                            //
                            parser.nextToken();
                            parser.skipChildren();
                        }
                    }
                }
                //parser.skipChildren();
            }
        }
    }

    /*
     * @description data group
     */ 
    public with sharing class DataGroup {
        public Map<String, DataUnit> dataMap;

        public DataGroup() {
            dataMap = new Map<String, DataUnit>();
        }

        public void parse(JSONParser parser) {
            if (parser.nextToken() == System.JSONToken.START_OBJECT) {
                while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                    if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                        String duName = parser.getCurrentName();
                        if (!dataMap.containsKey(duName)) {
                            System.debug('Data: ' + duName);
                            DataUnit du = new DataUnit();
                            dataMap.put(duName, du);

                            du.parse(parser);
                        }

                    } else {
                        // Invalid JSON
                    }
                }
                //parser.skipChildren();
            }
        }
    }

    /*
     * Static resource file name for the test data file
     */
    public String resourceName { get; set; }

    public Map<String, DataGroup> dgMap;
    
	public TestDataFile(String resFileName) {
        dgMap = new Map<String, DataGroup>();

		resourceName = resFileName;
        StaticResource testDataFile = [Select Id, Body From StaticResource Where Name = :resourceName];

        parse(testDataFile.Body.toString());
	}

    /*
     * Read, parse and load JSON string
     */
    public void parse(String jsonString) {
        //System.debug(jsonString);
        JSONParser parser = JSON.createParser(jsonString);
        if (parser.nextToken() == System.JSONToken.START_OBJECT) {
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String groupName = parser.getCurrentName();
                    if (groupName.startsWith('DG-')) { // Data Group
                        System.debug(groupName);
                        if (!dgMap.containsKey(groupName)) {
                            DataGroup dg = new DataGroup();
                            dgMap.put(groupName, dg);

                            dg.parse(parser);
                        }
                    }
                }
            }
        } else {
            System.debug('Error.');
        }

        system.debug(JSON.serialize(dgMap));
    }

}