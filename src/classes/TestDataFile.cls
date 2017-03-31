
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
        public String jpath;
        public Object value;
        
		public void parse(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentName() == 'cmd') {
					parser.nextValue();
					cmd = parser.getText();
				} else {
					jpath = parser.getCurrentName();
					System.JSONToken valToken = parser.nextValue();
					if (valToken == System.JSONToken.VALUE_TRUE) value = true;
					else if (valToken == System.JSONToken.VALUE_FALSE) value = false;
					else if (valToken == System.JSONToken.VALUE_NULL) value = null;
					else if (valToken == System.JSONToken.VALUE_NUMBER_FLOAT) value = parser.getDecimalValue();
					else if (valToken == System.JSONToken.VALUE_NUMBER_INT) value = parser.getLongValue();
					else value = parser.getText();
				}
			}
		}
    }
	/*
	 *
	 */
	public with sharing class JPathStack {
		List<String> fieldNames;
		String path;
		public JPathStack() {
			fieldNames = new List<String>();
			path = '$';
		}
		
		public void push(String fieldName) {
			fieldNames.add(fieldName);
			path = path + '.' + fieldName;
		}
		
		public String pop() {
			String fname = fieldNames.remove(fieldNames.size() - 1);
			recalcPath();
			return fname;
		}
		
		public void pushArray(Integer index) {
			String fn = '[' + String.valueOf(index) + ']';
			fieldNames.add(fn);
			path = path + fn;
		}
		
		public Integer popArray() {
			String fname = fieldNames.remove(fieldNames.size() - 1);
			recalcPath();
			return Integer.valueOf(fname.substring(1, fname.length() - 1));
		}
		
		public String getJPath() {
			return path;
		}
		
		void recalcPath() {
			path = '$';
			for (String fn : fieldNames) {
				path = path + '.' + fn;
			}
		}
	}
	/*
	 * @description JSON data
	 */
	public with sharing class JPathMap {
		Map<String, Object> dataMap;
		
		public JPathMap() {
			dataMap = new Map<String, Object>();
		}
		

		/*
		 *
		 */
		public void parseValue(JSONParser parser, JPathStack ps) {
			System.JSONToken token = parser.getCurrentToken();
			String jpath = ps.getJPath();
			if (token == System.JSONTOken.VALUE_FALSE) {
				dataMap.put(jpath, false);
			} else if (token == System.JSONTOken.VALUE_TRUE) {
				dataMap.put(jpath, true);
			} else if (token == System.JSONTOken.VALUE_NULL) {
				dataMap.put(jpath, null);
			} else if (token == System.JSONTOken.VALUE_STRING) {
				dataMap.put(jpath, parser.getText());
			} else if (token == System.JSONTOken.VALUE_NUMBER_FLOAT) {
				dataMap.put(jpath, parser.getDoubleValue());
			} else if (token == System.JSONTOken.VALUE_NUMBER_INT) {
				dataMap.put(jpath, parser.getIntegerValue());
			} 
		}
		
		/*
		 *
		 */
		public void parseArray(JSONParser parser, JPathStack ps) {
			Integer index = 0;
			while (parser.nextToken() != System.JSONToken.END_ARRAY) {
				ps.pushArray(index);
				System.JSONToken token = parser.getCurrentToken();
				
				if (token == System.JSONToken.START_OBJECT) {
					parseObject(parser, ps);
				} else if (token == System.JSONTOken.START_ARRAY) {
					parseArray(parser, ps);
				} else {
					parseValue(parser, ps);
				}
				
				ps.popArray();
				index += 1;
			}
			//parser.skipChildren();
		}
				
		/*
		 *
		 */
		public void parseObject(JSONParser parser, JPathStack ps) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String fieldName = parser.getCurrentName();
					ps.push(fieldName);
					System.JSONToken token = parser.nextToken();
					if (token == System.JSONToken.START_OBJECT) {
						parseObject(parser, ps);
					} else if (token == System.JSONTOken.START_ARRAY) {
						parseArray(parser, ps);
					} else {
						parseValue(parser, ps);
					}
					ps.pop();
				}
			}
		}

		/*
		 *
		 */
		public void parse(JSONParser parser) {
			if (parser.nextToken() == System.JSONToken.START_OBJECT) {
				JPathStack ps = new JPathStack();
				parseObject(parser, ps);
			}
		}
	}

    /*
     * @description data unit
     */
    public with sharing class DataUnit {
        public String unitType;
        public JPathMap data;
        public String path;
        public DataUnitAction[] actions;
        
        public DataUnit() {
        	data = new JPathMap();
        	actions = new List<DataUnitAction>();
        }

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
                            data.parse(parser);
                        } else if (fName == 'path') {
                            //
                            parser.nextValue();
                            path = parser.getText();
                        } else if (fName == 'action') {
                            //
                            if (parser.nextToken() == System.JSONToken.START_ARRAY) {
                            	while(parser.nextToken() != System.JSONToken.END_ARRAY) {
                            		if (parser.getCurrentToken() == System.JSONToken.START_OBJECT) {
                            			DataUnitAction action = new DataUnitAction();
                            			action.parse(parser);
                            			actions.add(action);
                            		}
                            	}
                            }
                            //parser.skipChildren();
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