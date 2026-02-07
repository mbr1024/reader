import { Injectable, ExecutionContext } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

/**
 * 可选的 JWT 认证守卫
 * 如果提供了有效的 token，会解析用户信息
 * 如果没有提供或无效，不会阻止请求，但 req.user 为 undefined
 */
@Injectable()
export class OptionalJwtAuthGuard extends AuthGuard('jwt') {
  canActivate(context: ExecutionContext) {
    return super.canActivate(context);
  }

  handleRequest(err: any, user: any) {
    // 不抛出错误，即使没有用户也允许继续
    return user || null;
  }
}
