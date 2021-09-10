# esx_documents
This a modify esx documents using meta data check out the video for more information

ShowCase : https://youtu.be/wO_RNlaLDtU

put this on linden inventory shared items.lua

['documents'] = {
	label = 'Documents',
	weight = 0.125,
	stack = false,
	close = true,
	client = {
		usetime = 0,
		event = 'mydocuments:show'
	}
},
