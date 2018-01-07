class XIIIQuickSLManager extends Actor;

VAR int ReturnCode, IsEmpty;
VAR XIIIConsole MyConsole;

function RequestQuickSave( )
{
    GotoState( 'QuickSaving' );
}

function RequestQuickLoad( )
{
    GotoState( 'QuickLoading' );
}

state QuickSaving
{
    function RequestQuickSave( );
    function RequestQuickLoad( );
begin:
    class'GUIController'.Static.RequestWriteSlot(0);
    while ( !class'GUIController'.Static.IsWriteSlotFinished(ReturnCode))
    {
        sleep( 0.1 );
    }
	if ( MyConsole!=none )
		MyConsole.qsManager = none;
    Destroy( );
}

state QuickLoading
{
    function RequestQuickSave( );
    function RequestQuickLoad( );
begin:
    class'GUIController'.Static.RequestIsSlotEmpty( 0 );
    while ( !class'GUIController'.Static.IsSlotEmptyFinished( ReturnCode, IsEmpty ) )
    {
        sleep( 0.1 );
    }

    if ( ReturnCode>=0 && IsEmpty == 0 )
    {
        class'GUIController'.Static.RequestReadSlot( 0 );
        while ( !class'GUIController'.Static.IsReadSlotFinished( ReturnCode ) )
        {
            sleep( 0.1 );
        }
    }

	if ( MyConsole!=none )
		MyConsole.qsManager = none;
    Destroy( );
}



defaultproperties
{
}
