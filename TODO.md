# TODO: Notificações de Suporte (SMS Admin/User)

## Objective
Implement notification sending when:
1. A user sends a support message → notify admin(s)
2. Admin replies to a support message → notify the user

## Steps

- [x] Step 0: Analyze codebase (HelpCenterService, functions/index.js, notification infrastructure)
- [x] Step 1: Create/edit `functions/index.js` - Add Cloud Function `onSupportMessageCreated` (trigger on `helpCenterMessages` onCreate → notify admins)
- [x] Step 2: Create/edit `functions/index.js` - Add Cloud Function `onSupportMessageReplied` (trigger on `helpCenterMessages` onUpdate when `adminReply` changes → notify user)
- [ ] Step 3: **Deploy the functions** - Run `firebase deploy --only functions` when ready

