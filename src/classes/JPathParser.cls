/*
 * @description JPathParser
 */
public with sharing class JPathParser {
	/*
	 * @description Enumeration of JPath node type
	 */
	public enum JPathNodeType { ObjectNode, ArrayNode }
	/*
	 * @description JPathNode class
	 */
	public class JPathNode {
		public JPathNodeType nodeType;
		public String name;
		
		public JPathNode(JPathNodeType nodeType, String name) {
			this.name = name;
			this.nodeType = nodeType;
		}
		
		public String getPathName() {
			if (nodeType == JPathNodeType.ArrayNode) {
				return '[' + name + ']';
			} else {
				if (name.contains(' ') || name.contains('.') || name.contains('$')) {
					return '"' + name + '"';
				} else {
					return name;
				}
			}
		}
	}

	/*
	 * @description pathNodes
	 */
	public List<JPathNode> pathNodes;
	/*
	 * @description constructor
	 */
	public JPathParser() {
		pathNodes = new List<JPathNode>();
	}
	
	/*
	 * @description push new jpath node of object type
	 */
	public void push(String jpathName) {
		pathNodes.add(new JPathNode(JPathNodeType.ObjectNode, jpathName));
	}
	
	/*
	 * @description push new jpath node of array type
	 */
	public void push(Integer arrayIndex) {
		pathNodes.add(new JPathNode(JPathNodeType.ArrayNode, String.valueOf(arrayIndex)));
	}
	
	/*
	 * @description pop the last jpath node out
	 */
	public JPathNode pop() {
		if (pathNodes.size() == 0) return null;
		
		JPathNode node = pathNodes.remove(pathNodes.size() - 1);
		return node;
	}
	
	/*
	 * @description return the full Jpath 
	 */
	public String getJpath() {
		String path = '$';
		for (JPathNode node : pathNodes) {
			if (node.nodeType == JPathNodeType.ArrayNode)
				path += node.getPathName();
			else
				path += '.' + node.getPathName();
		}
		
		return path;
	}
	
	/*
	 * @description helper method to throw 'Invalid char of "x" in "jpath" at "x" position.'
	 */
	void throwInvalidCharInJpathEx(String jpath, Integer index) {
		throw new AppException('Invalid char at {0} within "{1}" Jpath.');
	}
	
	/*
	 * @description parse the jpath string
	 */
	public void parse(String fullJpath) {
		pathNodes.clear();
		if (String.isEmpty(fullJpath)) return;
		
		Integer length = fullJpath.length();
		
		List<Integer> chArray = new List<Integer>();
		Integer chToken = fullJpath.charAt(0);
		if (chToken != 36) throwInvalidCharInJpathEx(fullJpath, 0); // Not starting with $
		Boolean closingQuote = false;
		for (Integer i = 1; i < length; i++) {
			Integer ch = fullJpath.charAt(i);
			
			if (ch == 91) { // [
				if (chToken == 34 && !closingQuote) chArray.add(ch); // within quote
				else if (chToken == 36 || chToken == 93) { // following $ or ]
					chToken = ch;
				} else if (chToken == 46 || (chToken == 34 && closingQuote)) { // . or " (right or closing)
					pathNodes.add(new JPathNode(JPathNodeType.ObjectNode, String.fromCharArray(chArray)));
					chArray.clear();
					chToken = ch;
				} else throwInvalidCharInJpathEx(fullJpath, i);
				
			} else if (ch == 93) { // ]
				if (chToken == 34 && !closingQuote) chArray.add(ch); // within quote
				else if (chToken == 91) {
					String arrIdx = String.fromCharArray(chArray);
					if (arrIdx.isNumeric()) {
						pathNodes.add(new JPathNode(JPathNodeType.ArrayNode, arrIdx));
						chArray.clear();
					} else {
						throw new AppException('"' + arrIdx + '" is invalid array index');
					}
					
					chToken = ch;
				} else {
					throwInvalidCharInJpathEx(fullJpath, i);
				}
				
			} else if (ch == 46) { // .
				if (chToken == 34 && !closingQuote) chArray.add(ch); // within quote
				else if (chToken == 46 || (chToken == 34 && closingQuote)) { // . or " (right or closing)
					pathNodes.add(new JPathNode(JPathNodeType.ObjectNode, String.fromCharArray(chArray)));
					chArray.clear();
					chToken = ch;
				} else if (chToken == 93 || chToken == 36) { // following ] or $, valid pattern
					chToken = ch;
				} else throwInvalidCharInJpathEx(fullJpath, i);
				
			} else if (ch == 36) { // $
				if (chToken == 34 && !closingQuote) chArray.add(ch); // within quote
				else throwInvalidCharInJpathEx(fullJpath, i);
			} else if (ch == 34) { // "
				if (chToken == 34 && !closingQuote) { // Within opening the quote, need to close it
					closingQuote = true;
				} else if (chToken == 46 || chToken == 36) { // follow $ or .
					chToken = ch;
				} else throwInvalidCharInJpathEx(fullJpath, i);
			} else {
				chArray.add(ch);
			}
		}
		
		if (chToken == 46 && chArray.size() > 0)
			pathNodes.add(new JPathNode(JPathNodeType.ObjectNode, String.fromCharArray(chArray)));
	}
	
	public static JPathParser createParser(String fullJpath) {
		JPathParser parser = new JPathParser();
		parser.parse(fullJpath);
		
		return parser;
	}
   
}