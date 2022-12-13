modded class PlayerBase	// modded keyword for modding an existing class
{
	override void OnJumpStart()	// overriding an existing method
	{
		super.OnJumpStart();			// call the original jump callback method so we don't break stuff
		Print("A pirate's life for me!");	// our modded print
	}
}