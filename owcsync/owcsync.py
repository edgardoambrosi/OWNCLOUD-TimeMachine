import owncloud

oc = owncloud.Client('http://ambrosi-fisico.ddns.net/owncloud')

oc.login('admin', '00505504')

oc.mkdir('testdir')
oc.delete('testdir')
oc.get_config()

oc.logout()
#oc.put_file('testdir/remotefile.txt', 'localfile.txt')

#link_info = oc.share_file_with_link('testdir/remotefile.txt')

#print "Here is your link: http://domain.tld/owncloud/" + link_info.link
