import {
  getDownloadURL,
  StorageReference,
  uploadBytesResumable,
} from "firebase/storage";

export const firebaseUpload = ({
  storageRef,
  buffer,
  mimetype,
}: {
  storageRef: StorageReference;
  buffer: Buffer;
  mimetype: string;
}) => {
  return new Promise<{ img_url: string }>((resolve, reject) => {
    const uploadTask = uploadBytesResumable(storageRef, buffer, {
      contentType: mimetype,
    });
    uploadTask.on(
      "state_changed",
      (snapshot) => {
        const progress =
          (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        console.log(`Upload is ${progress}% done`);
        switch (snapshot.state) {
          case "paused":
            console.log("Upload is paused");
            break;
          case "running":
            console.log("Upload is running");
            break;
        }
      },
      (error) => reject(`Fail to upload - ${error.message}`),
      () => {
        getDownloadURL(uploadTask.snapshot.ref).then((downloadUrl) =>
          resolve({ img_url: downloadUrl })
        );
      }
    );
  });
};
