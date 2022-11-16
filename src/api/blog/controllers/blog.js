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

    // const entity = await  await super.findOne(ctx);
    const sanitizedEntity = await this.sanitizeOutput(entity, ctx);

    return this.transformResponse(sanitizedEntity);
  },
}));
