/*
 * 
 */
public with sharing class JPathMap {
	/*
	 * @description JPath helper
	 */
	private with sharing class JPathGenerator {
		System.JSONGenerator generator;
		
		String prevJpath;
		String currentJpath;

		/*
		 * @description constructor
		 */
		public JPathGenerator() {
			generator = JSON.createGenerator(false);
			
			currentJpath = '';
			prevJpath = '';
		}
		
		/*
		 * @description
		 */
		public void write(String jpath, Object value) {
			prevJpath = currentJpath;
			currentJpath = jpath;
		}
		
	}
	
	/*
	 * @description convert to JPath value map from JSONParser
	 */
    public static Map<String, Object> convertJPathMap(JSONParser parser) {
    	Map<String, Object> jpathMap = new Map<String, Object>();
    	
    	JPathParser ps = new JPathParser();
    	parser.nextToken();
    	
		if (parser.getCurrentToken() == System.JSONToken.START_OBJECT) {
			parseObject(parser, ps, jpathMap);
		} else if (parser.getCurrentToken() == System.JSONToken.START_ARRAY) {
			parseArray(parser, ps, jpathMap);
		}
    	
    	return jpathMap;
    }    
    
	/*
	 * @description convert to JPath value map from JSON object
	 */
    public static Map<String, Object> convertJPathMap(Object jsonObj) {
    	if (jsonObj == null) return null;
    	
    	return convertJPathMap(JSON.serialize(jsonObj));
    }

	/*
	 * @description convert to JPath value map from JSON String
	 */
    public static Map<String, Object> convertJPathMap(String jsonString) {
    	if (jsonString == null) return null;
    	
    	JSONParser parser = JSON.createParser(jsonString);
    	return convertJPathMap(parser);
    }    
     
    /*
     * @description convert to JSON string from Jpath value map
     */
    public static String convertJSON(Map<String, Object> jpathMap) {
    	List<String> jpaths = new List<String>(jpathMap.keySet());
    	jpaths.sort();
    	
    	System.JSONGenerator gen = JSON.createGenerator(false);
    	
    	for (String jpath : jpaths) {
    		
    	}
    	return null;
    }
    
	/*
	 * parse JSON value
	 */
	private static void parseValue(JSONParser parser, JPathParser ps, Map<String, Object> jpathMap) {
		System.JSONToken token = parser.getCurrentToken();
		String jpath = ps.getJPath();
		if (token == System.JSONTOken.VALUE_FALSE) {
			jpathMap.put(jpath, false);
		} else if (token == System.JSONTOken.VALUE_TRUE) {
			jpathMap.put(jpath, true);
		} else if (token == System.JSONTOken.VALUE_NULL) {
			jpathMap.put(jpath, null);
		} else if (token == System.JSONTOken.VALUE_STRING) {
			jpathMap.put(jpath, parser.getText());
		} else if (token == System.JSONTOken.VALUE_NUMBER_FLOAT) {
			jpathMap.put(jpath, parser.getDoubleValue());
		} else if (token == System.JSONTOken.VALUE_NUMBER_INT) {
			jpathMap.put(jpath, parser.getIntegerValue());
		} 
	}
	
	/*
	 * parse JSON array
	 */
	private static void parseArray(JSONParser parser, JPathParser ps, Map<String, Object> jpathMap) {
		Integer index = 0;
		while (parser.nextToken() != System.JSONToken.END_ARRAY) {
			ps.push(index);
			System.JSONToken token = parser.getCurrentToken();
			
			if (token == System.JSONToken.START_OBJECT) {
				parseObject(parser, ps, jpathMap);
			} else if (token == System.JSONTOken.START_ARRAY) {
				parseArray(parser, ps, jpathMap);
			} else {
				parseValue(parser, ps, jpathMap);
			}
			
			ps.pop();
			index += 1;
		}
		//parser.skipChildren();
	}
			
	/*
	 * parse JSON object
	 */
	private static void parseObject(JSONParser parser, JPathParser ps, Map<String, Object> jpathMap) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String pathName = parser.getCurrentName();
				ps.push(pathName);
				System.JSONToken token = parser.nextToken();
				if (token == System.JSONToken.START_OBJECT) {
					parseObject(parser, ps, jpathMap);
				} else if (token == System.JSONTOken.START_ARRAY) {
					parseArray(parser, ps, jpathMap);
				} else {
					parseValue(parser, ps, jpathMap);
				}
				ps.pop();
			}
		}
	}

	/*
	 * 
	 */
	private static void processJPathValue(System.JSONGenerator generator, String prevJpath, String jpath, Object value) {
		
	}
}