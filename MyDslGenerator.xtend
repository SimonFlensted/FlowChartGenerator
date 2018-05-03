/*
 * generated by Xtext 2.13.0
 */
package org.xtext.example.mydsl1.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import org.xtext.example.mydsl1.myDsl.InputNode
import org.xtext.example.mydsl1.myDsl.Node
import org.xtext.example.mydsl1.myDsl.Relation

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class MyDslGenerator extends AbstractGenerator {
	
	int X=400
	int Y=100
	int WIDTH=120
	int HEIGHT=60
	boolean LEFT=true
	int LEVEL=1
	int X_CHANGE=160
	int Y_CHANGE=100

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		val inputNode = resource.allContents.filter(InputNode).next
		inputNode.generateChartFile(fsa);
	}
	
	def generateChartFile(InputNode in, IFileSystemAccess2 fsa) {

        fsa.generateFile("test.xml", in.generateChart);
		
    }
    
    def CharSequence reverseLeft() {LEFT = !LEFT ''''''}
    
	def CharSequence generateChart(InputNode inputNode) '''
	<?xml version="1.0" encoding="UTF-8"?>
	<mxGraphModel dx="1426" dy="738" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="827" pageHeight="1169" background="#ffffff" math="0" shadow="0">
	<root>
	<mxCell id="0"/>
	<mxCell id="1" parent="0"/>�inputNode.generateNode�
	�inputNode.relations.left.generateRelation(LEVEL, X)�
	�reverseLeft�
	�inputNode.relations.right.generateRelation(LEVEL, X)�
	
	</root>
	</mxGraphModel>'''
	
	def CharSequence generateRelation(Relation relation, int level, int parentX)'''
	�IF relation !== null� �relation.node.generateNode(level+1, parentX)�
	�ENDIF�
	'''
	
	def CharSequence generateNode(InputNode node)'''
	<mxCell id="�node.name�" value="�node.title�" style="rounded=0;whiteSpace=wrap;html=1;" vertex="1" parent="1">
	<mxGeometry x="�(X-WIDTH)/2�" y="�Y�" width="�WIDTH�" height="�HEIGHT�" as="geometry"/>
	</mxCell>'''
	
	def CharSequence generateNode(Node node, int level, int parentX)'''
	�IF LEFT�
		<mxCell id="�node.name�" value="�node.title�" style="rounded=0;whiteSpace=wrap;html=1;" vertex="1" parent="1">
		<mxGeometry x="�parentX-X_CHANGE*level�" y="�Y+Y_CHANGE*level�" width="�WIDTH�" height="�HEIGHT�" as="geometry"/>
		</mxCell>
		�IF node.relations !== null�
		 	�node.relations.left.generateRelation(level, parentX-X_CHANGE*level)� �reverseLeft� �node.relations.right.generateRelation(level, parentX-X_CHANGE*level)� 
		�ENDIF� 
	�ENDIF�
	 
	�IF !LEFT�
		<mxCell id="�node.name�" value="�node.title�" style="rounded=0;whiteSpace=wrap;html=1;" vertex="1" parent="1">
		<mxGeometry x="�parentX+X_CHANGE*level�" y="�Y+Y_CHANGE*level�" width="�WIDTH�" height="�HEIGHT�" as="geometry"/>
		</mxCell>
		�IF node.relations !== null�
		 	�node.relations.left.generateRelation(level, parentX+X_CHANGE*level)� �reverseLeft� �node.relations.right.generateRelation(level, parentX+X_CHANGE*level)� 
		�ENDIF� 
	�ENDIF�
	 
	

	
	'''
	
}
