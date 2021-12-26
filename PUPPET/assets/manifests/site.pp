node 'client.omar.edu' 
{
    include binddns::update, binddns::client_install, binddns::client_config
}

node 'agentcentos.omar.edu' 
{
    include lamp, binddns
}

node 'agentubuntu.omar.edu' 
{
    include lamp, binddns::update, binddns::client_install, binddns::client_config
}
