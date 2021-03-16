const functions = require("firebase-functions");
// refrencing firebase admin package and setting it to admin
const admin =  require('firebase-admin');
const { Change } = require("firebase-functions");
admin.initializeApp();
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// function to listen to when followers are created and then creates a timeline collection which contains 
// all posts of the followed user
//& using wildcard syntax as we dont know what the user id is going to be
exports.onCreateFollower = functions.firestore
.document("/followers/{userId}/userFollowers/{followerId}")
.onCreate(async(snapshot,context) => {
    // when new user is created
    console.log("Follower Created", snapshot.id);
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    // step 1 is to create followed user's posts ref
    const followedUserPostsRef = admin
    .firestore()
    .collection("posts")
    .doc(userId)
    .collection('userPosts');

    // step 2 create following user's timeline ref
    const timelinePostsRef = admin
    .firestore()
    .collection('timeline')
    .doc(followerId)
    .collection('timelinePosts');

    // step 3 is to get followed user posts
    const querySnapshot = await followedUserPostsRef.get();

    // add each user's post to the following timeline
    querySnapshot.forEach(doc => {
        if(doc.exists) {
            const postId = doc.id;
            const postData = doc.data();
            timelinePostsRef.doc(postId).set(postData);
        }
    });
});


 // fuction that deletes all the user posts of the user that is unfollowed
 exports.onDeleteFollower = functions.firestore
 .document("/followers/{userId}/userFollowers/{followerId}")
 .onDelete(async (snapshot,context) => {
    console.log("Follower Deleted",snapshot.id);

    const userId = context.params.userId;
    const followerId = context.params.followerId;
    // deleting posts by matching the owner id in the posts with the user id that is unfollowed
    const timelinePostsRef = admin
    .firestore()
    .collection('timeline')
    .doc(followerId)
    .collection('timelinePosts')
    .where("ownerId","==",userId);

    const querySnapshot = await timelinePostsRef.get();
    querySnapshot.forEach(doc => {
        if(doc.exists) {
            doc.ref.delete();
        }
    });
 });
// when a post is created,we add post to timeline of each follower (of post owner)
 exports.onCreatePost = functions.firestore
 .document('/posts/{userId}/userPosts/{postId}')
 .onCreate(async (snapshot, context) => {
    const postCreated = snapshot.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    // step 1 is to get all the followers of the user who made the post
    const userFollowersRef = admin
    .firestore()
    .collection("followers")
    .doc(userId)
    .collection('userFollowers');

    const querySnapshot = await userFollowersRef.get();

    //2nd step is to add new post to each followers timeline
    querySnapshot.forEach(doc => {
        const followerId = doc.id;

        admin
        .firestore()
        .collection('timeline')
        .doc(followerId)
        .collection('timelinePosts')
        .doc(postId)
        .set(postCreated);
    });
 });


 exports.onUpdatePost = functions.firestore
 .document('/posts/{userId}/userPosts/{postId}')
 .onUpdate(async (Change , context) => {
    const postUpdated = Change.after.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    // step 1 is to get all the followers of the user who made the post
    const userFollowersRef = admin
    .firestore()
    .collection("followers")
    .doc(userId)
    .collection('userFollowers');

    const querySnapshot = await userFollowersRef.get();

    //2nd step is to update each post in each followers timeline
    querySnapshot.forEach(doc => {
        const followerId = doc.id;

        admin
        .firestore()
        .collection('timeline')
        .doc(followerId)
        .collection('timelinePosts')
        .doc(postId)
        .get().then(doc => {
            if(doc.exists) {
                doc.ref.update(postUpdated);
            }
        });
    });
 });

 exports.onDeletePost = functions.firestore
 .document('/posts/{userId}/userPosts/{postId}')
 .onDelete(async (snapshot,context) => {

    const userId = context.params.userId;
    const postId = context.params.postId;

    // step 1 is to get all the followers of the user who made the post
    const userFollowersRef = admin
    .firestore()
    .collection("followers")
    .doc(userId)
    .collection('userFollowers');

    const querySnapshot = await userFollowersRef.get();

    //2nd step is to delete each post in each followers timeline
    querySnapshot.forEach(doc => {
        const followerId = doc.id;

        admin
        .firestore()
        .collection('timeline')
        .doc(followerId)
        .collection('timelinePosts')
        .doc(postId)
        .get().then(doc => {
            if(doc.exists) {
                doc.ref.delete();
            }
        });
    });
 });