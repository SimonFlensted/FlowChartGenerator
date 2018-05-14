	/*
	 * generated by Xtext 2.13.0
	 */
	package org.xtext.example.mydsl1.generator
	
	import org.eclipse.emf.ecore.resource.Resource
	import org.eclipse.xtext.generator.AbstractGenerator
	import org.eclipse.xtext.generator.IFileSystemAccess2
	import org.eclipse.xtext.generator.IGeneratorContext
	import org.xtext.example.mydsl1.myDsl.Node
	import org.xtext.example.mydsl1.myDsl.Relation
	import java.util.HashMap
	import org.xtext.example.mydsl1.myDsl.Plus
	import org.xtext.example.mydsl1.myDsl.Minus
	import org.xtext.example.mydsl1.myDsl.Mult
	import org.xtext.example.mydsl1.myDsl.Div
	import org.xtext.example.mydsl1.myDsl.Expression
	import org.xtext.example.mydsl1.myDsl.Num
	import org.xtext.example.mydsl1.myDsl.Constraint
	import org.xtext.example.mydsl1.myDsl.BasicExp
	import org.xtext.example.mydsl1.myDsl.BasicNode
	import org.xtext.example.mydsl1.myDsl.Chart
	import org.xtext.example.mydsl1.myDsl.InputNode

/**
	 * Generates code from your model files on save.
	 * 
	 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
	 */
	class MyDslGenerator extends AbstractGenerator {
	
	//��
		int WIDTH = 100
		int HEIGHT = 60
		int depthOfTree
		HashMap<String, int[]> indexes = new HashMap<String, int[]>()
		HashMap<String, String> color = new HashMap<String, String>() // 0=black, 1=red
		HashMap<String, Integer> outputs = new HashMap<String, Integer>()
	
		override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
			depthOfTree = 0
			val chart = resource.allContents.filter(Chart).next
			chart.inputNode.inputNode.generateIndexes
			System.out.println(chart.name + " depth " + depthOfTree)
			chart.generateChartFile(fsa);
		}
		
		def double getCanvasWidth() {
			400+100 * (Math.pow(2, depthOfTree))
		}
		
		def double getCanvasHeight() {
			100 * depthOfTree
		}		
	
		def generateChartFile(Chart chart, IFileSystemAccess2 fsa) {
	
			fsa.generateFile(chart.name + ".xml", chart.inputNode.inputNode.generateChart);
	
		}
		
		def InputNode getInputNode(BasicNode node) {
			switch node {
				InputNode: node
				Node: null
			}
		}
		
		def Node getNode(BasicNode node) {
			switch node {
				InputNode: null
				Node: node
			}
		}
		
	
		def void generateIndexes(InputNode input) {
	
			indexes.put(input.name, #[1, 0])
			val output = computeExp(input.inputFunction)
			val wasColoredLeft = input.putColor(input.relations.left, input.relations.left.node, output, true)
			val wasColoredRight = input.putColor(input.relations.right, input.relations.right.node, output, true)
			input.relations.left.node.generateLeftChildIndex(1, 1, output, wasColoredLeft)
			input.relations.right.node.generateRightChildIndex(1, 1, output, wasColoredRight)
		}
	
		def boolean putColor(BasicNode parent, Relation relation, Node child, int output, boolean doColor) {
			if (constraintHolds(relation.constraint, output) && doColor) {
				color.put(relation.node.name, "#FF3333")
				color.put(parent.name+child.name, "#FF3333")
				true
			} else {
				color.put(relation.node.name, "#000000")
				color.put(parent.name+child.name, "#000000")
				false
			}
		}
		
	
		def String getColor(String nodeName) {
			if (color.containsKey(nodeName)) {
				color.get(nodeName)
			} else {
				"#000000"
			}
		}
	
		def void generateLeftChildIndex(BasicNode node, int parentIndex, int level, int input, boolean doColor) {
			val index = parentIndex * 2 - 1
			indexes.put(node.name, #[index, level])
			generateChildren(node, index, level, input, doColor)
		}
		
		def void colorAndOutputNode(BasicNode node, int index, int level, int input, boolean doColor) {
			if (node.node.function !== null) {				
					val outputLeft = computeInputExp(node.node.function, input)
					node.putOutput(outputLeft)
					val wasColored = node.putColor(node.relations.left, node.relations.left.node, outputLeft, doColor)
					node.relations.left.node.generateLeftChildIndex(index, level + 1, outputLeft, wasColored)
				} else {
					node.relations.left.node.generateLeftChildIndex(index, level + 1, input, doColor)
					node.putOutput(input)
				}
				if (node.relations.right !== null) {
					if (node.node.function !== null) {
						System.out.println(node.name + " input="+input+" Function="+node.node.printFunction+" Result="+computeInputExp(node.node.function, input))
						val outputRight = computeInputExp(node.node.function, input)
						node.putOutput(outputRight)
						val wasColored = node.putColor(node.relations.right, node.relations.right.node, outputRight, doColor)				
						node.relations.right.node.generateRightChildIndex(index, level + 1, outputRight, wasColored)
					} else {
						node.relations.right.node.generateRightChildIndex(index, level + 1, input, doColor)
						node.putOutput(input)
					}
				}
		}
	
		def generateChildren(BasicNode node, int index, int level, int input, boolean doColor) {
			if (node.relations !== null) {
				node.colorAndOutputNode(index, level, input, doColor)	
			} else {
				node.putOutput(input)
				if (depthOfTree < level) {
					depthOfTree = level
				}
			}
		}
		
		def void putOutput(BasicNode node, int outputNode) {
			outputs.put(node.name, outputNode)
		}
		
		def int getOutput(BasicNode node) {
			System.out.println("node name " + node.name)
			System.out.println("node output " + outputs.get(node.name))
			if(node!==null) {
				if(outputs.containsKey(node.name)) {
					outputs.get(node.name)
				} else {
					0
				}
			
			} else {
				0
			}
		}
	
		def void generateRightChildIndex(BasicNode node, int parentIndex, int level, int input, boolean doColor) {
			val index = parentIndex * 2
			indexes.put(node.name, #[index, level])
			generateChildren(node, index, level, input, doColor)
		}
	
	// Gets index of node from map - used for positioning
		def int getIndex(BasicNode node) {
			indexes.get(node.name).get(0)
		}
	
	
	// Gets level of node from map - used for positioning
	
		def double getXPosition(BasicNode node) {
			node.getIndex * canvasWidth / (Math.pow(2, (node.getLevel)) + 1)
		}
	
		def double getYPosition(BasicNode node) {
			node.getLevel * canvasHeight / depthOfTree
		}
	
	// Gets level of node from map - used for positioning
		def int getLevel(BasicNode node) {
			indexes.get(node.name).get(1)
		}
	
		def double getXPosition(BasicNode node, boolean isLeft, boolean hasChildren) {
				if (isLeft) {
					node.getIndex * canvasWidth / (Math.pow(2, (node.getLevel))	 + 1) - (depthOfTree-node.level)*Math.sqrt(WIDTH)
				} else {
					node.getIndex * canvasWidth / (Math.pow(2, (node.getLevel)) + 1) + (depthOfTree-node.level)*Math.sqrt(WIDTH)
				}

		}
		
	
	
		def int computeExp(Expression exp) {
			switch exp {
				Plus: exp.left.computeExp() + exp.right.computeExp()
				Minus: exp.left.computeExp() - exp.right.computeExp()
				Mult: exp.left.computeExp() * exp.right.computeExp()
				Div: exp.left.computeExp() / exp.right.computeExp()
				Num: exp.value
				default: throw new Error("Invalid expression")
			}
	
		}
	
		def int computeInputExp(BasicExp exp, int input) {
			System.out.println("exp.left="+exp.left.sign+" " + exp.right.computeExp)
			switch exp.left.sign {
				case '+': input + exp.right.computeExp()
				case '-': input - exp.right.computeExp()
				case '*': input * exp.right.computeExp()
				case '/': input / exp.right.computeExp()
				default: throw new Error("Invalid expression")
			}
		}
	
		def boolean constraintHolds(Constraint constraint, int input) {
			switch constraint.left {
				case ">": input > computeExp(constraint.right)
				case "<": input < computeExp(constraint.right)
				case "<=": input <= computeExp(constraint.right)
				case ">=": input >= computeExp(constraint.right)
				case "=": input == computeExp(constraint.right)
				default: throw new Error("Invalid expression")			
				}		
		}
		
		def String printFunction(Node node) {
			if(node.function!==null) {
			"input " + node.function.left.sign + node.function.right.displayExp		
			} else {
				""
			}
		}
		
		def String displayExp(Expression exp) {
			switch exp {
				Plus: exp.left.displayExp+"+"+exp.right.displayExp
				Minus: exp.left.displayExp+"-"+exp.right.displayExp
				Mult: exp.left.displayExp+"*"+exp.right.displayExp
				Div: exp.left.displayExp+"/"+exp.right.displayExp
				Num: Integer.toString(exp.value)
				default: throw new Error("Invalid expression")
			}
		}
		
	
		def CharSequence generateChart(InputNode inputNode) '''
		<?xml version="1.0" encoding="UTF-8"?>
		<mxGraphModel dx="�canvasWidth�" dy="�canvasHeight�" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="827" pageHeight="1169" background="#ffffff" math="0" shadow="0">
		<root>
		<mxCell id="0"/>
		<mxCell id="1" parent="0"/>
		�inputNode.generateNode�
		�inputNode.relations.left.generateRelation(true)�
		�inputNode.relations.right.generateRelation(false)�
		�inputNode.relations.left.node.generateArrow(inputNode, true)�
		�inputNode.relations.right.node.generateArrow(inputNode, false)�
		</root>
		</mxGraphModel>'''
	
		def CharSequence generateRelation(Relation relation, boolean isLeft) '''
			�IF relation !== null�
				�relation.node.generateNode(isLeft)�
			�ENDIF�
		'''
	
		def CharSequence generateNode(InputNode node) '''
		<mxCell id="�node.name�" value="�node.title�&lt;br&gt;�node.inputFunction.displayExp�" style="rounded=0;whiteSpace=wrap;html=1;" vertex="1" parent="1">
		<mxGeometry x="�node.XPosition�" y="�node.YPosition�" width="�WIDTH�" height="�HEIGHT�" as="geometry"/>
		</mxCell>'''
	
		def CharSequence generateNode(BasicNode node, boolean isLeft) '''
			<mxCell id="�node.name�" value="�node.title�&lt;br&gt;�node.node.printFunction�&lt;br&gt;Output=�node.output�" style="rounded=0;whiteSpace=wrap;html=1;strokeColor=�getColor(node.name)�;" vertex="1" parent="1">
			<mxGeometry x="�node.getXPosition(isLeft, node.relations!==null)�" y="�node.YPosition�" width="�WIDTH�" height="�HEIGHT�" as="geometry"/>
			</mxCell>
			�IF node.relations !== null�
				�node.relations.left.generateRelation(true)� 
				�node.relations.right.generateRelation(false)�		
				�node.relations.left.node.generateArrow(node, true)�
				�IF node.relations.right!==null�
				�node.relations.right.node.generateArrow(node, false)�
				�ENDIF�
			�ENDIF�
		'''
	
		def CharSequence generateArrow(BasicNode node, BasicNode parent, boolean isLeft) '''
			<mxCell id="�parent.name+node.name�" value="�parent.displayConstraint(isLeft)�" style="endArrow=classic;endSize=16;html=1;exitX=0.5;exitY=1;strokeColor=�getColor(parent.name+node.name)�;" parent="1" source="�parent.name�" edge="1">
			<mxGeometry width="50" height="50" relative="1" as="geometry">
			<mxPoint x="�parent.getXPosition(isLeft, false)�" y="�parent.YPosition�" as="sourcePoint"/>
			<mxPoint x="�node.getXPosition(isLeft, false)+(WIDTH/2)�" y="�node.YPosition�" as="targetPoint"/>
			</mxGeometry>
			</mxCell>
		'''
		
		
		def String displayConstraint(BasicNode node, boolean isLeft) {
			if(isLeft) {
				node.relations.left.constraint.displayContraint + " " + node.relations.left.constraint.right.displayExp
			} else {
				node.relations.right.constraint.displayContraint + " " + node.relations.right.constraint.right.displayExp
			}
		}
		
		def String displayContraint(Constraint c) {
			switch c.left {
				case "<": "&amp;lt;"
				case ">": "&amp;gt;"
				case ">=": "&amp;gt;="
				case "<=": "&amp;lt;="
				case "=": "="
			}
		}
	
	}
