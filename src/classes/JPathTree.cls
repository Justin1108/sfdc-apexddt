/*
 * @description
 */
public with sharing class JPathTree {
    /*
     * @description TreeNode class
     */
    public with sharing virtual class TreeNode {
    	/*
    	 * @description node type
    	 */
    	public JPathParser.JPathNodeType nodeType;
    	/*
    	 * @description name of the JSON object node
    	 */
    	public String name { get; private set; }
    	/*
    	 * @description index of the array if it's an array node
    	 */
    	public Integer index;
    	/*
    	 * @description value of the JSON object if it's leaf node
    	 */
    	public Object value;
    	/*
    	 * @description child nodes if it's not a leaf node
    	 */
    	public List<TreeNode> childNodes;
    	/*
    	 * @description parent tree node
    	 */
    	public TreeNode parentNode;
    	
    	public TreeNode(JPathParser.JPathNodeType nodeType) { 
    		this(nodeType, null);
    	}
    	public TreeNode(JPathParser.JPathNodeType nodeType, String name) {
    		this.nodeType = nodeType; 
    		this.name = name;
    		childNodes = new List<TreeNode>();
    	}

    }
    
    /*
     * @description root node of the tree
     */
    public with sharing class TreeRoot extends TreeNode {
    	public TreeRoot(JPathParser.JPathNodeType nodeType) {
    		super(nodeType);
    	}
    }
}