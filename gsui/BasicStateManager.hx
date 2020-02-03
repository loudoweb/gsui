package gsui;

import gsui.interfaces.IState;
import gsui.interfaces.IStateManager;
import haxe.ds.StringMap;

/**
 * Link one class per state
 * @usage <themes groups="theme" state="themes" classes="MyThemes" /> : it will call MyThemes class when state 'themes' is reached.
 * @author Ludovic Bas - www.lugludum.com
 */
class BasicStateManager implements IStateManager 
{
	var _states:StringMap<IState>;
	var _currentState:IState;
	
	var _currentStateName:String;
	var _previousStateName:String;
	
	public function new() 
	{
		_currentStateName = "";
		_previousStateName = "";
		_states = new StringMap<IState>();
	}
	
	/**
	 * TODO generate by macro all call to addState
	 * @param	namestate
	 */
	public function addState(name:String, state:IState):Void
	{
		if (!_states.exists(name))
		{
			_states.set(name, state);
		}
	}
	
	public function update(time:Float):Void
	{
		if (_currentState != null)
			_currentState.update(time);
	}
	
	/* INTERFACE gsui.interfaces.IState */
	
	public function changeState(state:String):Void 
	{
		if (_states.exists(state))
		{
			_previousStateName = _currentStateName;
			
			if (_states.exists(_previousStateName))
				_states.get(_previousStateName).onRemoved();
			
			_currentStateName = state;
			_currentState = _states.get(_currentStateName);
			_currentState.onAdded();
		}
	}
	
	public function getBackToPreviousState():Void 
	{
		changeState(_previousStateName);
	}
	
	public function isState(state:String):Bool 
	{
		return _currentStateName == state;
	}
	
}