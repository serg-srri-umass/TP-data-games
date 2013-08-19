// File src/com/kcpt/scriptInterface/ScriptInterface.as
// import com.kcpt.scriptInterface.ScriptInterface;


package common {

	import flash.external.ExternalInterface;
	
	import mx.controls.Alert;

	/**
	* The ScriptInterface manages communication between a flex application and a Fathom/Tinkerplots container.
	*/
	public class ScriptInterface {
	
	/**
	* Creates a new collection with the given name and the given attributes.
	* <p>Caller can subsequently assume that the FTP container deal appropriately with changes to the collection.
	* For example, it is immaterial to caller if the user reorders, renames, or deletes attributes, or renames the collection.</p>
	* <p>If the caller requests creation of a collection created by a previous call to NewCollectionWithAttributes(), the
	* existing collection is left as is and the result is true. In this case the array of attribute names is ignored. “previous call”
	* includes calls that happened before a save / restore of the document.</p>
	* <p>Passing fewer values than the number of original attributes is not an error. Remaining attributes will get null
	* values for the new case.</p>
	* 
	* @param iCollectionName The name of the collection to be created.
	* @param iAttributeNames Names for each of the attributes.
 	* @return true if creation of the new collection was successful, false otherwise. 
	*/
		
	public	static	function	LogUserAction( actionType:String, data:Array ) : Boolean	
	{
		return CallContainerWithArrayArgs("LogUserAction", actionType, data);
	}
		
	public static function NewCollectionWithAttributes(iCollectionName: String, iAttributeNames:Array) : Boolean
	{
		return CallContainerWithArrayArgs("NewCollectionWithAttributes", iCollectionName, iAttributeNames);
	}
	
	/**
	* Adds a case to the collection. The values are assigned to the case attributes matching the order of creation.
	* 
	* <p>Caller can assume that the original order of attribute specification holds. It is up to FTP to handle deviations from this assumption; e.g. when user has reordered attributes.</p>
	* <p>Caller need not worry about possibility that the name of the collection has changed. Mapping original name to the proper collection will be handled by FTP.</p>
	* <p>Passing fewer values than the number of original attributes is not an error. Remaining attributes will get null values for the new case.</p>
	* 
	* @param iCollectionName The name of a collection previously created by the client.
	* @param iAttributeNames an array of strings each of which is a value for an attribute where the order of values is assumed to be the order of the attributes in a previous call to NewCollectionWithAttributes.
 	* @return false if:
 	*		- The Collection referenced by iCollectionName does not exist.
	*		- There are more values than were originally created in the collection.
	*		- The creation of the case fails for any reason.
	*	true otherwise.
	*/
	public static function AddCaseToCollectionWithValues(iCollectionName: String, iValues:Array) : Boolean
	{
		return CallContainerWithArrayArgs("AddCaseToCollectionWithValues", iCollectionName, iValues);
	}
	
	/**
	* Signals the container that activation has occurred.
	*/
	public static function signalActivation() : Boolean
	{
		return CallContainer("HandleFlashActivation");
	}
	
	/**
	* Signals the container that deactivation has occurred.
	*/
	public static function signalDeactivation() : Boolean
	{
		return CallContainer("HandleFlashDeactivation");
	}
	
	/**
	 @private
	*/
	private static function XMLReturnToBoolean(iXMLReturn:String):Boolean
	{
	
		var ret:Boolean = Boolean(iXMLReturn);
		return ret;
	}
	
	/**
	 @private
	 * 
	 * Stringification functor.
	*/
	private static function makeString(element:*, index:int, arr:Array):String {
		return String(element);
	}

	/**
	 @private
	*/
	private static function CallContainerWithArrayArgs(iStatementKind:String, iCollectionName:String, iValues:Array):Boolean
	{
		if( ExternalInterface.available)
		{
			var	preConversion:String;
			
			preConversion = ExternalInterface.call(iStatementKind, iCollectionName, iValues.map(makeString));
			return XMLReturnToBoolean(preConversion);
		}
				
		return false;
	}
	
	/**
	 * doCommand implementation!
	 * NOTE: capitalize DoCommand on JS side :)
	 * */
	
	public static function	doCommand( args:String ):String	{
		
		var	result:String = ExternalInterface.call("DoCommand", args);
		
		//	Alert.show( "result: " + result + "\n" + args, "Return from doCommand") ;
		return	 result ;
		
	}
	
	
	/**
	 @private
	*/
	private static function CallContainer(iStatementKind:String):Boolean
	{
		if( ExternalInterface.available)
		{
			return XMLReturnToBoolean( ExternalInterface.call(iStatementKind));
		}
				
		return false;
	}
	
	}
}