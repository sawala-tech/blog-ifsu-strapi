"use strict";

/**
 * blog controller
 */

const { createCoreController } = require("@strapi/strapi").factories;

module.exports = createCoreController("api::blog.blog", ({ strapi }) => ({
  async findOne(ctx) {
    const { id } = ctx.params;
    const { query } = ctx;
    const blogs = await strapi.entityService.findMany("api::blog.blog", {
      filters: {
        slug: id,
      },
    });
    if (blogs.length == 0) {
      return ctx.notFound();
    }
    const entity = await strapi
      .service("api::blog.blog")
      .findOne(blogs[0]?.id, query);

    //get the next blog by id
    const nextBlog = await strapi.entityService.findMany("api::blog.blog", {
      filters: {
        id: {
          $gt: blogs[0]?.id,
        },
      },
      sort: "id:asc",
      limit: 1,
    });

    //get the previous blog by id
    const previousBlog = await strapi.entityService.findMany("api::blog.blog", {
      filters: {
        id: { $lt: blogs[0]?.id },
      },
      sort: "id:desc",
      limit: 1,
    });

    entity.nextBlog = nextBlog[0] || null;
    entity.previousBlog = previousBlog[0] || null;

    // const entity = await  await super.findOne(ctx);
    const sanitizedEntity = await this.sanitizeOutput(entity, ctx);

    return this.transformResponse(sanitizedEntity);
  },
}));
