"use strict";

const slugify = (str) =>
  str
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, "")
    .replace(/[\s_-]+/g, "-")
    .replace(/^-+|-+$/g, "");
const makeid = (length) => {
  var result = "";
  var characters = "abcdefghijklmnopqrstuvwxyz0123456789";
  var charactersLength = characters.length;
  for (var i = 0; i < length; i++) {
    result += characters.charAt(Math.floor(Math.random() * charactersLength));
  }
  return result;
};
module.exports = {
  async afterCreate(event) {
    const { result } = event;
    console.log(result);
    await strapi.entityService.update("api::blog.blog", result.id, {
      data: {
        slug: slugify(result.title) + "-" + makeid(9),
      },
    });
  },
};
